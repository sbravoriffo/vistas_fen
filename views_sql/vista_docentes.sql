-- Vista_Docentes
SELECT
    d.Cod_Persona,
    -- Nombre completo, posiblemente redundante (preguntar)
    UPPER(CONCAT(p.Apellido1, ' ', p.Apellido2, ' ', p.Nombre1)) AS Academico,
    -- Departamento Vigente con Part-Time
    (CASE 
        WHEN (d.DepartamentoVigente IS NULL) OR (d.DepartamentoVigente = 'SIN DATOS')
            THEN 'PART-TIME'
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
    LEFT JOIN
        dbo.Personas AS p
        ON d.Cod_Persona = p.Cod_Persona