/******************************
** ARCHIVO
    vista_cursos.sql
** AUTOR
    Fernando Palomera
** FECHA ULTIMA MODIFICACION
    04/08/2020 
** DESCRIPCION
    Generar una vista con los campos calculados más utilizados para reportes sobre cursos
** DETALLES:
    Incluye:
        - Total de alumnos por Curso
        - Tipo de cátedra del curso: Core, No Core y Tésis
    Filtros:
        - Cursos eliminados de la programación docente
**************************/
SELECT
    CONCAT(u.Periodo, u.Cod_Catedra, u.Cod_Seccion) AS ID_Curso,
    u.Periodo, u.Cod_Catedra, u.Cod_Seccion, 
    -- Año Académico, considerando a semestre de verano como perteneciente al año anterior
    (CASE 
        WHEN RIGHT(u.Periodo, 1) IN ('1', '2', 'B', 'C', 'D', 'E', 'F') 
            THEN LEFT(u.Periodo, 4)
        WHEN RIGHT(u.Periodo, 1) IN ('0', 'A')
            THEN LEFT(u.Periodo, 4) - 1
        END) AS Año_Academico,
    -- Escuela de la cátedra (Pregrado o Postgrado FT/Executive)
    (CASE
        WHEN RIGHT(u.Cod_Catedra, 3) < 600 AND RIGHT(u.Periodo, 1) LIKE '[0-2]'
            THEN 'PREGRADO'
        WHEN RIGHT(u.Cod_Catedra, 3) >= 600 AND RIGHT(u.Periodo, 1) LIKE '[0-2]'
            THEN 'POSTGRADO FULL-TIME'
        WHEN RIGHT(u.Periodo, 1) LIKE '[A-F]'
            THEN 'POSTGRADO EXECUTIVE'
        END) AS Escuela_Catedra,
    -- Tipo Cátedra {CORE, NO CORE, TESIS}
    (CASE
        WHEN u.Cod_Catedra IN (
            'ENPOL850', 'ENECO853', 'ENECO851', 'ENPOL850', 'ENMKT852', 'ENMKT850', 
            'ENMAN851', 'ENFIN851', 'ENFIN850', 'ENECO852', 'ENECO850', 'ENCGE851', 
            'ENCGE850', 'ENMAN850', 'ENNEG550', 'ENECO550') 
            THEN 'TESIS'
        WHEN 
            -- Prácticas, Seminarios Postgrado Executive
            (SUBSTRING(u.Cod_Catedra, 3, 3) IN ('PRA', 'PRC', 'SEM', 'ELC', 'SEL'))
            -- Tutorías
            OR (RIGHT(u.Cod_Catedra, 3) < 100)
            THEN 'OTROS'
        WHEN SUBSTRING(u.Cod_Catedra, 3, 3) IN (
            'AUD', 'CGE', 'CON', 'ECO', 'FIN', 'GEP', 'GIN', 'HEC', 'IMP', 'MAC', 
            'MAN', 'MEC', 'MES', 'MIC', 'MKT', 'NEG', 'OPE', 'SIA', 'TAX', 'STA', 
            'POL', 'GES')
            THEN 'CORE'
        WHEN SUBSTRING(u.Cod_Catedra, 3, 3) IN (
            'APP', 'AUS', 'CFG', 'CSH', 'COM', 'ELE', 'DEP', 'ESO', 'FEN', 'FGF', 'FOI', 'IDI', 
            'LEG', 'MEM', 'FGU', 'HAB', 'DER', 'MAT', 'LIB', 'ING', 'ESP', 'TAL')
            THEN 'NO CORE'
        ELSE 'OTROS'
        END) AS Tipo_Catedra,
    n.Curso_Alumnos
FROM
    dbo.Cursos AS u
        LEFT JOIN
        -- Total Alumnos por curso
        (
        SELECT 
            Periodo, Cod_Catedra, Cod_Seccion, 
            COUNT(Cod_Alumno) AS Curso_Alumnos
        FROM 
            dbo.Movimientos_Inscripcion 
        WHERE 
            Estado = 'ACEPTADA' 
            AND TipoMovimiento = 'AGREGA'
        GROUP BY
            Periodo, Cod_Catedra, Cod_Seccion
        ) AS n
        ON u.Periodo = n.Periodo 
            AND u.Cod_Catedra = n.Cod_Catedra 
            AND u.Cod_Seccion = n.Cod_Seccion
WHERE
    -- Cursos efectivamente realizados
    u.Eliminado = 0
    -- Filtrar Cursos Antiguos
    AND ISNUMERIC(RIGHT(u.Cod_Catedra, 3)) = 1