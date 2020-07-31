# Vistas de SAD para reportes en Power BI

## Tabla de Contenidos

* [Acerca del Proyecto](#acerca-del-proyecto)
* [Herramientas Utilizadas](#herramientas-utilizadas)
* [Cómo Usar](#cómo-usar)
* [Memoria de Cálculo](#memoria-de-cálculo)
    * [Vista_Alumnos](#vista_alumnos)
    * [Vista_Docentes](#vista_docentes)
    * [Vista_Cursos](#vista_alumnos)
    * [Vista_DocentesCursos](#vista_docentescursos)

## Acerca del Proyecto

![Esquema_Vistas](https://github.com/fdopalomera/vistas_fen/blob/master/esquema_vistas1.1.png?raw=true)

Proyecto de Vistas de SQL (Views) para utilizarse en reportes de Power BI de la FEN.
Son 4 entidades (Alumnos, Docentes, Cursos y Docentes_Cursos) de los cuales se han cálculado los campos calculados más utilizados, entre otros atributos, para un mayor control y consistencia de las métricas a lo largo de toda la organización.

## Herramientas Utilizadas

* [SQL](https://code.visualstudio.com/download)
* [ERD Preview](https://marketplace.visualstudio.com/items?itemName=kaishuu0123.vscode-erd-preview)

## Cómo Usar
Una vez inciado Power BI, puede seguir los siguientes pasos para importar estas vistas como tablas en su esquema para el reporte:

1) Seleccionar _Obtener Datos_, para luego seleccionar la opción de "Base de SQL Server", o directamente desde las opciones _SQL_Server_ o de _Origenes Recientes_, siendo recomendable esta última si anteriormente ha establecido una conexión a las bases de SAD.
2) Sí se solicita, ingresar 
3) En el buscador
4) En la Pestaña, . Para el caso de _Vista_Cursos_ y _Vista_DocentesCursos_
5) __*Opcional*:__ Sí desea utilizar campos adicionales proveniente de otras tablas cuya relación se establece con múliples campos como llaves (Ej: Tabla _Cursos_ para relacionar con _Vista_Cursos_), cree una nueva columna  
6) Apoyese de la 

## Memoria de Cálculo

### Vista_Alumnos

#### Filtros
* Solo se registran alumnos ingresados desde el año 2000. 
* Se omite en todos los cálculos las cátedras extracurriculares.
#### Atributos
* __Cod_Alumno__:  Código identificador único del alumno.
* __Año_Ingreso__: Año en el cual se registra el ingreso del alumno (no la persona) a la facultad, extraído a partir del periodo de `Sem_IngresoDecreto` de la tabla _Alumnos_.
* __Escuela__: División de la facultad a la que pertence el alumno según el programa de estudios. Cálculado a partir de `Tipo_Alumno` de la tabla _Alumnos_, pudiendo obtener los valores de PREGRADO (IC, IICG , CA) LIBRE (LIBRE, LIBREPOST) o POSTGRADO (todos los demás programas)
* __Prom_AprobReprob__: Promedio ponderado entre las notas y los créditos obtenidos de las cátedras aprobadas y reprobadas que el alumno posee hasta el momento de la consulta, omitiendose los cursos extracurriculares.  
* __Cred_Aprob__: Suma de todos los créditos de las cátedras aprobadas (cursadas o reconocidas) del alumno.
* __Cred_Reprob__: Suma de todos los créditos de las cátedras reprobadas (cursadas o reconocidas) por el alumno. 
* __Cred_Pend__: Suma de todos los créditos de las cátedras en estado pendiente (actualmente cursandose o con evalauciones pendientes) del alumno.
* __Cred_Curs__: Suma de todos los créditos de las cátedras cursadas (aprobadas, reprobadas o pendientes) del alumno.
* __Cred_Recon__:  Suma de todos los créditos de las cátedras reconocidas (aprobadas o reprobadas) del alumno.

### Vista_Docentes

#### Filtros
* Ninguno, presenta la misma cantidad de registros que la tabla _Docentes_.

#### Campos
* __Cod_Persona__: Código identificador único de la persona, generalmente el RUT.
* __Academico__: Nombre del docente, concatenando `Apellido1`, `Apellido2` y `Nombre1` de la tabla _Personas_.
* __DeptoVigente__: Departamento al cual pertenece al momento de la consulta el docente. Se genera a partir del campo `DepartamentoVigente` de la tabla _Docentes_, transformando los valores SIN DATOS o valores nulos (NULL en SQL) en PART-TIME.
* __Jerarquia__: Rango y categoría del docente de acuerdo a la carrera académica de la Universidad de Chile. Proveninete del campo con el mismo nombre de la tabla _Docentes_, cambiando solamente los títulos femeninos a masculinos, para no crear categorías dobles en los reportes. Ej: Instructora Adjunta -> Instructor Adjunto

### Vista_Cursos

#### Filtros
* No se registran cusos eliminados de la progrmación docente. 
* No se registran cursos con código de cátrdas antiguos, donde los útlimos 3 caractéres de su `Cod_Catedra` no son exclusivamente números. Ej: FAC0405

#### Campos
* __Periodo__: Semestre (o Bimestre en Postgrado Executive) cuando fue o es impartida la cátedra.
* __Cod_Catedra__: Código identificador de la cátedra impartida. 
* __Cod_Seccion__: Código identificador de la sección correspondiente al curso.
* __ID_Curso__: Llave única para c/curso creada para utilizarse en la construcción de relaciones en Power BI. Se genera a través de la concatenación de `Periodo`, `Cod_Catedra` y `Cod_Seccion`.
* __Año_Academico__: Año en el cual el curso es impartido. Se considera a los semestres de verano en Pregrado y Postgrado Executive, y el primer bimestre de Postgrado Executive (valores de `Periodo` terminados en '0' y 'A', respectivamente)  
* __Escuela__: Escuela de la facultad encargada de impartir el curso. Para el caso de que la cátedra es impartida en un semestre (valores de `Periodo` terminados en '0', '1', '2'), si el valor de `Cod_Catedra` es menor a 600, se considera de PREGRADO; e igual o superior a 600 se considera como POSTGRADO FULL-TIME. En cambio todas las cátedras impartidas en bimestres (valor de `Periodo` terminadas en letras de la 'A' a la 'F') se considera pertenecientes a POSTGRADO EXECUTIVE.
* __Tipo_Catedra__: Categoría en la cual se clasifica la cátedra, pudiendo ser CORE, NO CORE o TESIS. Se clasifica como TESIS si en el campo `Cod_Catedra` la cátedra tiene como valor: 'ENPOL850', 'ENECO853', 'ENECO851', 'ENPOL850', 'ENMKT852', 'ENMKT850', 'ENMAN851', 'ENFIN851', 'ENFIN850', 'ENECO852', 'ENECO850', 'ENCGE851', 'ENCGE850', 'ENMAN850', 'ENNEG550' o 'ENECO550'. En cambio se clasifica como CORE si el área de la cátedra se encunetra en la siguiente lista: 'AUD', 'CGE', 'COM', 'CON', 'ECO', 'FIN', 'GEP', 'GIN', 'HEC', 'IMP', 'MAC', 'MAN', 'MEC', 'MES', 'MIC', 'MKT', 'NEG', 'OPE', 'SIA', 'TAL', 'TAX', 'STA', 'POL', 'GES'. Y como NO CORE a los cursos cuya área sean: 'APP', 'AUS', 'CFG', 'CSH', 'ELE', 'DEP', 'ESO', 'FEN', 'FGF', 'FOI', 'IDI', 'LEG', 'MEM', 'SEL', 'FGU', 'HAB', 'DER', 'MAT', 'LIB', 'ING', 'ESP'.
* __Curso_Alumnos__: Total de alumnos registrados como inscritos en el curso al momento de la consulta.

### Vista_DocentesCursos
* __Periodo__: Semestre (o Bimestre en Postgrado Executive) cuando fue o es impartida la cátedra.
* __Cod_Catedra__: Código identificador de la cátedra impartida. 
* __Cod_Seccion__: Código identificador de la sección correspondiente al curso.
* __ID_Curso__: Llave única para c/curso creada para utilizarse en la construcción de relaciones en Power BI. Se genera a través de la concatenación de _Periodo_, _Cod_Catedra_ y _Cod_Seccion_.
* __EvaDocente_p1p3p4__:
* __EvaDocente_p1a12__:
* __EvaDocente_Encuestados__:
* __Carga_Academica__:

<!-- Pendientes(Test) -->
<!-- Contribuyentes --->





