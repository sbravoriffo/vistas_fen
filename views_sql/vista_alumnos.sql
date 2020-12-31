/******************************
** ARCHIVO
    vista_alumnos.sql
** AUTOR
    Fernando Palomera
** FECHA ULTIMA MODIFICACION
    30/12/2020 
** DESCRIPCION
    Generar una vista con los campos calculados más utilizados para reportes sobre alumnos
** DETAILS
    Incluye:
        Cantidad de Créditos aprobados, reprobados, pendientes, cursados y reconocidos
        Promedio de notas de cátedras aprobadas y reprobadas
    Filtros:
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
    (CASE WHEN c.Creditos_Aprobados_Cursados IS NULL THEN 0 ELSE c.Creditos_Aprobados_Cursados END) AS Cred_Aprob_Curs,
    (CASE WHEN c.Asignaturas_Aprobadas_Cursadas IS NULL THEN 0 ELSE C.Asignaturas_Aprobadas_Cursadas END) AS Asign_Aprob_Curs,
    c.Promedio_Aprobadas_Cursadas AS Prom_Aprob_Curs,
    (CASE WHEN c.Creditos_Aprobados_Cursados_Reconocidos IS NULL THEN 0 ELSE c.Creditos_Aprobados_Cursados_Reconocidos END) AS Cred_Aprob_Curs_Recon,
    (CASE WHEN c.Asignaturas_Aprobadas_Cursadas_Reconocidas IS NULL THEN 0 ELSE c.Asignaturas_Aprobadas_Cursadas_Reconocidas END) AS Asign_Aprob_Curs_Recon,
    c.Promedio_Aprobadas_Cursadas_Reconocidas AS Prom_Aprob_Curs_Recon,
    (CASE WHEN c.Creditos_Aprobados_Reprobados_Cursados IS NULL THEN 0 ELSE c.Creditos_Aprobados_Reprobados_Cursados END) AS Cred_Aprob_Reprob_Curs,
    (CASE WHEN c.Asignaturas_Aprobadas_Reprobadas_Cursadas IS NULL THEN 0 ELSE c.Asignaturas_Aprobadas_Reprobadas_Cursadas END) AS Asign_Aprob_Reprob_Curs,
    c.Promedio_Aprobadas_Reprobadas_Cursadas AS Prom_Aprob_Reprob_Curs,
    c.Promedio_Aprobadas_Reprobadas_Cursadas_Reconocidas AS Prom_Aprob_Reprob_Curs_Recon
   
FROM
    dbo.Alumnos AS a
    LEFT JOIN 
        (
        SELECT DISTINCT ac.Cod_Alumno,	
				ROUND(CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Nota IS NOT NULL AND ac.Categoria IN('CURSADA', 'RECONOCIDA') AND ac.Sit_Catedra='APROBADA'
				THEN ac.Nota*ac.Ud END) OVER (PARTITION BY ac.Cod_Alumno) AS float) 
			/
			NULLIF(CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Nota IS NOT NULL AND ac.Categoria IN('CURSADA', 'RECONOCIDA') AND ac.Sit_Catedra='APROBADA'
				THEN ac.Ud END) OVER (PARTITION BY ac.Cod_Alumno) AS float),0),3) AS Promedio_Aprobadas_Cursadas_Reconocidas,

				CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Categoria IN('CURSADA', 'RECONOCIDA') AND ac.Sit_Catedra='APROBADA'
				THEN ac.Ud END) OVER (PARTITION BY ac.Cod_Alumno) AS float) AS Creditos_Aprobados_Cursados_Reconocidos,

				CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Categoria IN('CURSADA', 'RECONOCIDA') AND ac.Sit_Catedra='APROBADA'
				THEN 1 END) OVER (PARTITION BY ac.Cod_Alumno) AS float) AS Asignaturas_Aprobadas_Cursadas_Reconocidas,
--
				ROUND(CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Nota IS NOT NULL AND ac.Categoria IN('CURSADA', 'RECONOCIDA') AND ac.Sit_Catedra!='PENDIENTE'
				THEN ac.Nota*ac.Ud END) OVER (PARTITION BY ac.Cod_Alumno) AS float) 
			/
				NULLIF(CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Nota IS NOT NULL AND ac.Categoria IN('CURSADA', 'RECONOCIDA') AND ac.Sit_Catedra!='PENDIENTE'
				THEN ac.Ud END) OVER (PARTITION BY ac.Cod_Alumno) AS float),0),3) AS Promedio_Aprobadas_Reprobadas_Cursadas_Reconocidas,

				CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Categoria IN('CURSADA', 'RECONOCIDA') AND ac.Sit_Catedra!='PENDIENTE'
				THEN ac.Ud END) OVER (PARTITION BY ac.Cod_Alumno) AS float) AS Creditos_Aprobados_Reprobados_Cursados_Reconocidos,

				CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Categoria IN('CURSADA', 'RECONOCIDA') AND ac.Sit_Catedra!='PENDIENTE'
				THEN 1 END) OVER (PARTITION BY ac.Cod_Alumno) AS float) AS Asignaturas_Aprobadas_Reprobadas_Cursadas_Reconocidas,

--			
				ROUND(CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Nota IS NOT NULL AND ac.Categoria IN('CURSADA') AND ac.Sit_Catedra!='PENDIENTE'
				THEN ac.Nota*ac.Ud END) OVER (PARTITION BY ac.Cod_Alumno) AS float) 
			/
				NULLIF(CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Categoria IN('CURSADA')  AND ac.Sit_Catedra!='PENDIENTE'
				THEN ac.Ud END) OVER (PARTITION BY ac.Cod_Alumno) AS float),0),3) AS Promedio_Aprobadas_Reprobadas_Cursadas,

				CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Categoria IN('CURSADA')  AND ac.Sit_Catedra!='PENDIENTE'
				THEN ac.Ud END) OVER (PARTITION BY ac.Cod_Alumno) AS float) AS Creditos_Aprobados_Reprobados_Cursados,

				CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Categoria IN('CURSADA')  AND ac.Nota IS NOT NULL AND ac.Sit_Catedra!='PENDIENTE'
				THEN 1 END) OVER (PARTITION BY ac.Cod_Alumno) AS float) AS Asignaturas_Aprobadas_Reprobadas_Cursadas,

--
				ROUND(CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Nota IS NOT NULL AND ac.Categoria IN('CURSADA') AND ac.Sit_Catedra='APROBADA'
				THEN ac.Nota*ac.Ud END) OVER (PARTITION BY ac.Cod_Alumno) AS float) 
			/
				NULLIF(CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Categoria IN('CURSADA')  AND ac.Sit_Catedra='APROBADA'
				THEN ac.Ud END) OVER (PARTITION BY ac.Cod_Alumno) AS float),0),3) AS Promedio_Aprobadas_Cursadas,

			    CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Categoria IN('CURSADA')  AND ac.Sit_Catedra='APROBADA'
				THEN ac.Ud END) OVER (PARTITION BY ac.Cod_Alumno) AS float)
				 AS Creditos_Aprobados_Cursados,

				CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Categoria IN('CURSADA')  AND ac.Sit_Catedra='APROBADA'
				THEN 1 END) OVER (PARTITION BY ac.Cod_Alumno) AS float) AS Asignaturas_Aprobadas_Cursadas,

				CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Categoria IN('CURSADA')  AND ac.Sit_Catedra='REPROBADA'
				THEN 1 END) OVER (PARTITION BY ac.Cod_Alumno) AS float)
				 AS Cursos_Reprobados_Cursados,

				CAST(SUM(CASE WHEN ac.EstadoCatedra IS NULL AND ac.Categoria IN('CURSADA', 'RECONOCIDA')  AND ac.Sit_Catedra='REPROBADA'
				THEN 1 END) OVER (PARTITION BY ac.Cod_Alumno) AS float)
				 AS Cursos_Reprobados_Cursados_Reconocidos
FROM Alumnos_Catedras AS ac
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
