-- Vista_Docentes
SELECT
    c.Cod_Persona,
    -- Nombre completo
    UPPER(CONCAT(p.Apellido1, ' ', p.Apellido2, ' ', p.Nombre1)) AS Academico,
    (CASE 
        WHEN d.DeptoVigente IS NULL 
            THEN 'PART-TIME'
        ELSE d.DeptoVigente
        END) AS Departamento,
    (CASE 
        WHEN d.Jerarquia IS NULL 
            THEN 'SIN DATOS'
        ELSE d.Jerarquia 
        END) AS Jerarquia
FROM
    -- Profesores que han sido asignados a al menos un curso impartido en la FEN
    (
    SELECT
        DISTINCT
        Cod_Profesor AS Cod_Persona
    FROM
        Cursos_Profesores AS p
        LEFT JOIN
            Cursos AS u
            ON p.Periodo = u.Periodo
                AND p.Cod_Catedra = u.Cod_Catedra
                AND p.Cod_Seccion = u.Cod_Seccion
    WHERE
        Tipo = 'CATEDRA'
        AND u.Eliminado = 0
    ) AS c
    LEFT JOIN
        (
        SELECT 
            Cod_Persona,
            -- Departamento Vigente con Part-Time
            (CASE 
                WHEN (d.DepartamentoVigente IS NULL) OR (d.DepartamentoVigente = 'SIN DATOS')
                    THEN 'PART-TIME'
                WHEN d.DepartamentoVigente IN ('ESCUELAS DE PREGRADO', 'ESCUELA DE POSTGRADO')
                    THEN 'ESCUELAS'
                ELSE d.DepartamentoVigente
                END) AS DeptoVigente,
            -- Jerarquía con homogeneización de género
            (CASE
                WHEN LEFT(d.Jerarquia, 18) = 'PROFESORA ASOCIADA' 
                    THEN REPLACE(d.Jerarquia, 'PROFESORA ASOCIADA', 'PROFESOR ASOCIADO')
                WHEN LEFT(d.Jerarquia, 17) = 'PROFESORA ADJUNTA' 
                    THEN REPLACE(d.Jerarquia, 'PROFESORA ADJUNTA', 'PROFESOR ADJUNTO')
                WHEN LEFT(d.Jerarquia, 9) = 'PROFESORA' 
                    THEN REPLACE(d.Jerarquia, 'PROFESORA', 'PROFESOR')
                WHEN LEFT(d.Jerarquia, 20) = 'INSTRUCTORA ASOCIADA' 
                    THEN REPLACE(d.Jerarquia, 'INSTRUCTORA ASOCIADA', 'INSTRUCTOR ASOCIADO')
                WHEN LEFT(d.Jerarquia, 19) = 'INSTRUCTORA ADJUNTA' 
                    THEN REPLACE(d.Jerarquia, 'INSTRUCTORA ADJUNTA', 'INSTRUCTOR ADJUNTO')
                WHEN LEFT(d.Jerarquia, 11) = 'INSTRUCTORA' 
                    THEN REPLACE(d.Jerarquia, 'INSTRUCTORA', 'INSTRUCTOR')
                ELSE d.Jerarquia
            END) AS Jerarquia
        FROM 
            dbo.Docentes AS d
        ) AS d
        ON c.Cod_Persona = d.Cod_Persona
    LEFT JOIN
        dbo.Personas AS p
        ON c.Cod_Persona = p.Cod_Persona