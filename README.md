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
2) Ingresar 
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
* __Cod_Alumno__:  Código identificador del alumno.
* __Año_Ingreso__: Año en el cual se registra el ingreso del alumno (no la persona) a la facultad, extraído a partir del periodo de `Sem_IngresoDecreto` de la tabla _Alumnos_.
* __Escuela__: División de la facultad a la que pertence el alumno según el programa de estudios. Cálculado a partir de `Tipo_Alumno` de la tabla _Alumnos_, pudiendo obtener los valores de PREGRADO (IC, IICG , CA) LIBRE (LIBRE, LIBREPOST) o POSTGRADO (todos los demás programas)
* __Prom_AprobReprob__: Promedio ponderado entre las notas y los créditos obtenidos de las cátedras aprobadas y reprobadas que el alumno posee hasta el momento de la consulta, omitiendose los cursos extracurriculares.  
* __Cred_Aprob__: Suma de todos los créditos aprobados 
* __Cred_Reprob__:  
* __Cred_Pend__:  
* __Cred_Curs__:  
* __Cred_Recon__:  

### Vista_Docentes
* __Cod_Persona__:
* __Academico__:
* __DeptoVigente__:
* __Jerarquia__:

### Vista_Cursos
* __Periodo__: Semestre (o Bimestre en Postgrado Executive) cuando fue o es impartida la cátedra.
* __Cod_Catedra__: Código identificador de la cátedra impartida. 
* __Cod_Seccion__: Código identificador de la sección correspondiente al curso.
* __ID_Curso__: Llave única para c/curso creada para utilizarse en la construcción de relaciones en Power BI. Se genera a través de la concatenación de _Periodo_, _Cod_Catedra_ y _Cod_Seccion_.
* __Año_Academico__: 
* __Escuela__:
* __Tipo_Catedra__:
* __Curso_Alumnos__:

### Vista_DocentesCursos
* __Periodo__: Semestre (o Bimestre en Postgrado Executive) cuando fue o es impartida la cátedra.
* __Cod_Catedra__: Código identificador de la cátedra impartida. 
* __Cod_Seccion__: Código identificador de la sección correspondiente al curso.
* __ID_Curso__: Llave única para c/curso creada para utilizarse en la construcción de relaciones en Power BI. Se genera a través de la concatenación de _Periodo_, _Cod_Catedra_ y _Cod_Seccion_.
* __EvaDocente_p1p3p4__:
* __EvaDocente_p1a12__:
* __EvaDocente_Encuestados__:
* __Carga_Academica__:








