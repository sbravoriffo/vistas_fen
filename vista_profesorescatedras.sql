/******************************
** ARCHIVO
    vista_profesorescatedras.sql
** AUTOR
    Fernando Palomera
** FECHA ULTIMA MODIFICACION
    27/07/2020 
** DESCRIPCION
    Generar una vista con los campos calculados más utilizados para reportes de docentes
** DETALLES:
    Incluye:
        Año Académico contando semestres de verano como pertenecientes al año anterior
            ej: Periodo: 20190 -> Año_Pregrado: 2018
        Evaluación Docente (3 métricas y cantidad de encuestados)
        Carga Académica
    Filtros:
        Cursos eliminados en la programación docente no son considerados
    *Realizar para cálculos de Carga Académica
    Pendiente:
        - OTROS TALLESRES, PRACTICAS ANTIGUAS, TALLER DE INTEGRACION PROFESIONAL, ANTONIO FARIAS?
        - Revisar año académico Postgrado Executive
**************************/

SELECT
    t.Periodo,
    t.Cod_Catedra, 
    t.Cod_Seccion,
    t.Cod_Profesor AS Cod_Persona,
    -- Año_Pregrado, considerando a semestre de verano como perteneciente al año anterior
    (CASE 
        WHEN RIGHT(t.Periodo, 1) IN ('1', '2') THEN LEFT(t.Periodo, 4)
        WHEN RIGHT(t.Periodo, 1) = '0' THEN LEFT(t.Periodo, 4) - 1
        END) AS Año_Academico,
    -- Nombre completo, posiblemente redundante (preguntar)
    UPPER(CONCAT(p.Apellido1, ' ', p.Apellido2, ' ', p.Nombre1)) AS Nombre_Profesor,
    -- Departamento Vigente con Part-Time
    (CASE 
        WHEN (d.DepartamentoVigente IS NULL) OR (d.DepartamentoVigente = 'SIN DATOS')
            THEN 'PART-TIME'
        ELSE d.DepartamentoVigente
        END) AS Profesores_DeptoVigente,
    -- Jerarquía con homogeneización de género
    (CASE
        WHEN LEFT(d.Jerarquia, 9) = 'PROFESORA ASOCIADA' 
            THEN REPLACE(d.Jerarquia, 'PROFESORA ASOCIADA', 'PROFESOR ASOCIADO')
        WHEN LEFT(d.Jerarquia, 9) = 'PROFESORA ADJUNTA' 
            THEN REPLACE(d.Jerarquia, 'PROFESORA ADJUNTA', 'PROFESOR ADJUNTA')
        WHEN LEFT(d.Jerarquia, 9) = 'PROFESORA' 
            THEN REPLACE(d.Jerarquia, 'PROFESORA', 'PROFESOR')
        WHEN LEFT(d.Jerarquia, 9) = 'INSTRUCTORA ASOCIADA' 
            THEN REPLACE(d.Jerarquia, 'INSTRUCTORA ASOCIADA', 'INSTRUCTOR ASOCIADO')
        WHEN LEFT(d.Jerarquia, 9) = 'INSTRUCTORA ADJUNTA' 
            THEN REPLACE(d.Jerarquia, 'INSTRUCTORA ADJUNTA', 'ISNTRUCTOR ASOCIADO')
        WHEN LEFT(d.Jerarquia, 9) = 'INSTRUCTORA' 
            THEN REPLACE(d.Jerarquia, 'INSTRUCTORA', 'INSTRUCTOR')
        ELSE d.Jerarquia
        END) AS Profesores_Jerarquia,
    t.Cod_Catedra, t.Cod_Seccion,
    -- Escuela de la cátedra (Pregrado o Postgrado FT/Executive)
    (CASE
        WHEN RIGHT(t.Cod_Catedra, 3) < 600 AND RIGHT(t.Periodo, 1) LIKE '[0-2]'
            THEN 'PREGRADO'
        WHEN RIGHT(t.Cod_Catedra, 3) >= 600 AND RIGHT(t.Periodo, 1) LIKE '[0-2]'
            THEN 'POSTGRADO FULL-TIME'
        WHEN RIGHT(t.Periodo, 1) LIKE '[A-F]'
            THEN 'POSTGRADO EXECUTIVE'
        END) AS Escuela_Catedra,
    -- Carga Académica
    (CASE 
        WHEN t.Cod_Catedra IN (
            -- Practicas
            'ENTAL305', 'ENTAL355', 'ENTAL405', 'ENTAL500', 'ENTAL510',
            -- Tesis
            'ENPOL850', 'ENECO853', 'ENECO851', 'ENPOL850', 'ENMKT852', 'ENMKT850', 'ENMAN851', 
            'ENFIN851', 'ENFIN850', 'ENECO852', 'ENECO850', 'ENCGE851', 'ENCGE850', 'ENMAN850', 
            'ENNEG550', 'ENECO550') 
            THEN 0
        WHEN t.Cod_Catedra IN ('ENTAL265', 'ENTAL260') 
            THEN ROUND(((1.0 / CAST(COUNT(*) OVER(PARTITION BY t.Periodo, t.Cod_Catedra, t.Cod_Seccion) AS FLOAT)) / 2.0), 2)
        ELSE ROUND((1.0 / CAST(COUNT(*) OVER(PARTITION BY t.Periodo, t.Cod_Catedra, t.Cod_Seccion) AS FLOAT)), 2)
        END) AS Carga_Academica,
    e.EvaDocente_p1p3p4,
    e.EvaDocente_p1a12,
    e.EvaDocente_Nota,
    e.EvaDocente_Encuestas

FROM
    dbo.Cursos_Profesores AS t
    LEFT JOIN
        dbo.Docentes AS d
        ON t.Cod_Profesor = d.Cod_Persona
    LEFT JOIN
        dbo.Personas AS p
        ON t.Cod_Profesor = p.Cod_Persona
    LEFT JOIN
        dbo.Cursos AS c
        ON t.Periodo = c.Periodo
            AND t.Cod_Catedra = c.Cod_Catedra
            AND t.Cod_Seccion = c.Cod_Seccion
    LEFT JOIN
        -- Tabla con Evaluación Docente promedio de cursos específico
        (
        SELECT
            Periodo, Cod_Profesor, Cod_Catedra, Cod_Seccion, 
            ROUND(((AVG(P1_1)+ AVG(P1_3)+ AVG(P1_4))/3), 3) AS EvaDocente_p1p3p4,
            ROUND(((AVG(P1_1)+ AVG(P1_2)+AVG(P1_3)+AVG(P1_4)
            +AVG(P1_5)+AVG(P1_6)+AVG(P1_7)+AVG(P1_8)
            +AVG(P1_9)+AVG(P1_10)+AVG(P1_11)+AVG(P1_12))/12), 3) AS EvaDocente_p1a12,
            ROUND(AVG(Nota), 3) AS EvaDocente_Nota,
            COUNT(*) AS EvaDocente_Encuestas
        FROM
            dbo.Evaluacion_Docente_Docentes
        GROUP BY 
            Periodo, Cod_Profesor, Cod_Catedra, Cod_Seccion
        ) AS e
        ON t.Periodo = e.Periodo
            AND t.Cod_Catedra = e.Cod_Catedra
            AND t.Cod_Seccion = e.Cod_Seccion
            AND t.Cod_Profesor = e.Cod_Profesor                 
WHERE
    -- Solo docentes profesores
    Tipo = 'CATEDRA'
    -- Sin contar cursos eliminados
    AND c.Eliminado = 0
    -- Filtrar Cursos Antiguos
    AND ISNUMERIC(RIGHT(t.Cod_Catedra, 3)) = 1
