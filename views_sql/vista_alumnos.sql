/******************************
** ARCHIVO
    vista_alumnos.sql
** AUTOR
    Fernando Palomera
** FECHA ULTIMA MODIFICACION
    30/07/2020 
** DESCRIPCION
    Generar una vista con los campos calculados más utilizados para reportes sobre alumnos
** DETAILS
    Incluye:
        Cantidad de Créditos aprobados, reprobados, pendientes, cursados y reconocidos
        Promedio de notas de cátedras aprobadas y reprobadas
    Filtros:
        Ingresos desde el año 2020
        No considerar alumnos 'introductorios' y otros casos por definir en detalle.
    Pendiente:
    - Revisar Tipo_Alumno, Cod_SitAcademica
    - Sistema de UD para postgrado (depende de decreto)
**************************/
SELECT
    a.Cod_Alumno,
    (CAST(LEFT(a.Sem_IngresoDecreto, 4) AS int)) AS Año_Ingreso,
    (CASE
        WHEN a.Tipo_Alumno IN ('IC', 'IICG', 'CA')
            THEN 'PREGRADO'
        WHEN a.Tipo_Alumno IN ('LIBRE', 'LIBREPOST')
            THEN 'LIBRE'
        ELSE 'POSTGRADO'
        END) AS Escuela,
    ---PENDIENTE: Unidad SISTEMA: Credítos o Ud
    (CASE WHEN Cred_Aprob IS NULL THEN 0 ELSE Cred_Aprob END) AS Cred_Aprob,
    (CASE WHEN Cred_Reprob IS NULL THEN 0 ELSE Cred_Reprob END) AS Cred_Reprob,
    (CASE WHEN Cred_Pend IS NULL THEN 0 ELSE Cred_Pend END) AS Cred_Pend,
    (CASE WHEN Cred_Curs IS NULL THEN 0 ELSE Cred_Curs END) AS Cred_Curs,
    (CASE WHEN Cred_Recon IS NULL THEN 0 ELSE Cred_Recon END) AS Cred_Recon,
    Prom_AprobReprob 
FROM
    dbo.Alumnos AS a
    LEFT JOIN 
        (
        SELECT
            Cod_Alumno, 
            -- Créditos Aprobados Totales
            SUM((CASE WHEN Sit_Catedra = 'APROBADA' THEN Ud END)) AS Cred_Aprob,
            -- Créditos Reprobados Totales
            SUM((CASE WHEN Sit_Catedra = 'REPROBADA' THEN Ud END)) AS Cred_Reprob,
            -- Créditos Pendiente Totales
            SUM((CASE WHEN Sit_Catedra = 'PENDIENTE' THEN Ud END)) AS Cred_Pend,
            -- Créditos Cursados Totales
            SUM((CASE WHEN Categoria = 'CURSADA' THEN Ud END)) AS Cred_Curs,
            -- Créditos Reconocidos Totales
            SUM((CASE WHEN Categoria = 'RECONOCIDA' THEN Ud END)) AS Cred_Recon,
            -- Promedio de Notas Aprobadas y Reprobadas
            (CASE
                WHEN SUM(Ud) > 0 AND SUM(Nota*Ud) > 0 THEN
            (ROUND(CAST(SUM(
                        CASE 
                            WHEN Nota IS NOT NULL
                            THEN Nota*Ud END) AS float)
                    / (CAST(SUM(
                        CASE 
                            WHEN Nota IS NOT NULL
                            THEN Ud END) AS float)),3))
                END) AS Prom_AprobReprob
        FROM
            Alumnos_Catedras
        WHERE
            Categoria IN ('CURSADA', 'RECONOCIDA')
            -- Sin contar extracurriculares
            AND EstadoCatedra IS NULL
        GROUP BY
            Cod_Alumno
        ) AS c
        ON a.Cod_Alumno = c.Cod_Alumno
WHERE
    -- No considerar Alumnos cambio malla 2012 'G' ni 'LD'
    LEFT(a.Cod_Alumno, 2) != 'LD' 
    AND LEFT(a.Cod_Alumno, 1) != 'G'
    AND LEFT(a.Cod_Alumno, 5) != 'INTRO'
    -- No considerar como alumnos a los 'introductorios'
    AND a.Tipo_Alumno NOT IN ('INTRO')
    AND a.Cod_SitAcademica NOT IN ('CONVOCADO', 'NO MATRICULADO')
    -- Ingresos desde el año 2000
    AND LEFT(Sem_IngresoDecreto, 4) >= 2000