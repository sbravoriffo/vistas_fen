/******************************
** ARCHIVO
    vista_cursos.sql
** AUTOR
    Fernando Palomera
** FECHA ULTIMA MODIFICACION
    27/07/2020 
** DESCRIPCION
    Generar una vista con los campos calculados más utilizados para reportes sobre cursos
** DETALLES:
    Incluye:
        - Total de alumnos por Curso
        - Tipo de cátedra del curso: Core, No Core y Tésis
    Filtros:
        - Cursos eliminados de la programación docente
    Pendiente:
    - Curso_Alumnos nulo: cambiar a 0?
**************************/
SELECT
    u.Periodo, u.Cod_Catedra, u.Cod_Seccion, 
    -- Tipo Cátedra {CORE, NO CORE, TESIS}
    (CASE 
        WHEN SUBSTRING(u.Cod_Catedra, 3, 3) IN (
            'AUD', 'CGE', 'COM', 'CON', 'ECO', 'FIN', 'GEP', 'GIN', 'HEC', 'IMP', 'MAC', 
            'MAN', 'MEC', 'MES', 'MIC', 'MKT', 'NEG', 'OPE', 'SIA', 'TAL', 'TAX', 'STA', 
            'POL', 'GES')
            THEN 'CORE'
        WHEN SUBSTRING(u.Cod_Catedra, 3, 3) IN (
            'APP', 'AUS', 'CFG', 'CSH', 'ELE', 'DEP', 'ESO', 'FEN', 'FGF', 'FOI', 'IDI', 
            'LEG', 'MEM', 'SEL', 'FGU', 'HAB', 'DER', 'MAT', 'LIB', 'ING', 'ESP')
            THEN 'NO CORE'
        WHEN u.Cod_Catedra IN (
            'ENPOL850', 'ENECO853', 'ENECO851', 'ENPOL850', 'ENMKT852', 'ENMKT850', 
            'ENMAN851', 'ENFIN851', 'ENFIN850', 'ENECO852', 'ENECO850', 'ENCGE851', 
            'ENCGE850', 'ENMAN850', 'ENNEG550', 'ENECO550') 
            THEN 'TESIS'
        ELSE NULL
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
