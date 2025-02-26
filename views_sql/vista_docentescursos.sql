/******************************
** ARCHIVO
    vista_profesorescatedras.sql
** AUTOR
    Fernando Palomera
** FECHA ULTIMA MODIFICACION
    30/07/2020 
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
**************************/

SELECT
    CONCAT(t.Periodo, t.Cod_Catedra, t.Cod_Seccion) AS ID_Curso, 
    t.Periodo,
    t.Cod_Catedra, 
    t.Cod_Seccion,
    t.Cod_Profesor AS Cod_Persona,
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
