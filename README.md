# Vistas de SAD para reportes en Power BI

## Tabla de Contenidos

- [Acerca del Proyecto](#acerca-del-proyecto)
- [Herramientas Utilizadas](#herramientas-utilizadas)
- [Cómo Usar](#cómo-usar)
- [Memoria de Cálculo](#memoria-de-cálculo)
  - [Vista_Alumnos](#vista_alumnos)
  - [Vista_Docentes](#vista_docentes)
  - [Vista_Cursos](#vista_cursos)
  - [Vista_DocentesCursos](#vista_docentescursos)


## Acerca del Proyecto

![Esquema_Vistas](https://github.com/fdopalomera/vistas_fen/blob/master/views_schema/esquema_vistas1.2.png?raw=true)

Proyecto de Vistas de SQL (Views) para utilizarse en reportes de Power BI de la FEN.
Son 4 entidades (Alumnos, Docentes, Cursos y Docentes_Cursos) de los cuales se han cálculado los campos calculados más utilizados, entre otros atributos, para un mayor control y consistencia de las métricas a lo largo de toda la organización.

## Herramientas Utilizadas

* [SQL](https://code.visualstudio.com/download)
* [ERD Preview](https://marketplace.visualstudio.com/items?itemName=kaishuu0123.vscode-erd-preview)

## Cómo Usar

Una vez inciado Power BI, puede seguir los siguientes pasos para importar estas vistas como tablas en su esquema para el reporte:

1) Seleccionar _Obtener Datos_, para luego seleccionar la opción de "Base de SQL Server", o directamente desde las opciones _SQL_Server_ o de _Origenes Recientes_, siendo recomendable esta última si anteriormente ha establecido una conexión a las bases de SAD.
2) Si se solicita, completar los cuadros con los datos necesarios para establecer la conexión a la base de datos con los permisos necesarios.
3) En el buscador, busque las tablas que empiecen con "BI" para seleccionar las tablas con las vistas, para luego buscar e  importar todas las tablas de SAD que posean los campos que necesite para realizar el reporte.
4) En la pestaña de "Modelo", relacione las tablas según lo indicado en el [esquema de las vistas](#acerca-del-proyecto), arrastrando la _llave_ de una tabla a la _llave_ correspondiente de la tabla a unir. Por ejemplo: desde _Vista_Alumnos_ arrastre `Cod_Persona` hacia el campo `Cod_Persona` de la tabla _Alumnos_.
Para el caso de _Vista_Cursos_ y _Vista_DocentesCursos_.
5) Automaticamente aparecerá un cuadro que indicará el tipo de Cardinalidad que se genera. En practicamente todos los casos, la relación será 1:1 o 1:varios, debiendo no aparecer varios a varios. Presionando en "Aceptar" se crea la relación entre las tablas. 

6) __*Opcional*:__ Sí desea utilizar campos adicionales 
proveniente de otras tablas de SAD cuya relación se establece con múliples campos como llave (Ej: Tabla _Cursos_ para relacionar con _Vista_Cursos_), cree una nueva columna en la tabla de SAD que sea homologa a `ID_Curso` de _Vista_Cursos_.

## Memoria de Cálculo

### Vista_Alumnos

#### Filtros

* Solo se registran alumnos ingresados desde el año 2000. 
* Se omite en todos los cálculos las cátedras extracurriculares.
* No se consideran como alumnos estudiantes de cursos introductorios, o convocados pero no matriculados en la factultad, ni tampoco estudiantes cuyo `Cod_Alumno` empiecen con 'LD' o 'G'.

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

* Solo se considera como docentes a profesores que hayan impartido al menos una cátedra en la FEN, y que esta no haya sido eliminada de la progrmación docente.

#### Campos

* __Cod_Persona__: Código identificador único de la persona, generalmente el RUT.
* __Academico__: Nombre del docente, concatenando `Apellido1`, `Apellido2` y `Nombre1` de la tabla _Personas_.
* __Departamento__: Departamento al cual pertenece al momento de la consulta el docente. Se genera a partir del campo `DepartamentoVigente` de la tabla _Docentes_, transformando los valores SIN DATOS o valores nulos (NULL en SQL) en PART-TIME, además de incluir en el valor "ESCUELAS" los profesores pertenecientes tanto a las escuelas de pregrado como postgrado.
* __Jerarquia__: Rango y categoría del docente de acuerdo a la carrera académica de la Universidad de Chile. Proveninete del campo con el mismo nombre de la tabla _Docentes_, cambiando solamente los títulos femeninos a masculinos, para no crear categorías dobles en los reportes. Ej: Instructora Adjunta -> Instructor Adjunto

### Vista_Cursos

#### Filtros

* No se registran cursos eliminados de la progrmación docente. 
* No se registran cursos con código de cátrdas antiguos, donde los útlimos 3 caractéres de su `Cod_Catedra` no son exclusivamente números. Ej: FAC0405

#### Campos

* __Periodo__: Semestre (o Bimestre en Postgrado Executive) cuando fue o es impartida la cátedra.
* __Cod_Catedra__: Código identificador de la cátedra impartida. 
* __Cod_Seccion__: Código identificador de la sección correspondiente al curso.
* __ID_Curso__: Llave única para c/curso creada para utilizarse en la construcción de relaciones en Power BI. Se genera a través de la concatenación de `Periodo`, `Cod_Catedra` y `Cod_Seccion`.
* __Año_Academico__: Año en el cual el curso es impartido. Se considera a los semestres de verano en Pregrado y Postgrado Executive, y el primer bimestre de Postgrado Executive (valores de `Periodo` terminados en '0' y 'A', respectivamente)  
* __Escuela__: Escuela de la facultad encargada de impartir el curso. Para el caso de que la cátedra es impartida en un semestre (valores de `Periodo` terminados en '0', '1', '2'), si el valor de `Cod_Catedra` es menor a 600, se considera de PREGRADO; e igual o superior a 600 se considera como POSTGRADO FULL-TIME. En cambio todas las cátedras impartidas en bimestres (valor de `Periodo` terminadas en letras de la 'A' a la 'F') se considera pertenecientes a POSTGRADO EXECUTIVE.
* __Tipo_Catedra__: Categoría en la cual se clasifica la cátedra, pudiendo ser CORE, NO CORE o TESIS. Se clasifica como TESIS si en el campo `Cod_Catedra` la cátedra tiene como valor: 'ENPOL850', 'ENECO853', 'ENECO851', 'ENPOL850', 'ENMKT852', 'ENMKT850', 'ENMAN851', 'ENFIN851', 'ENFIN850', 'ENECO852', 'ENECO850', 'ENCGE851', 'ENCGE850', 'ENMAN850', 'ENNEG550' o 'ENECO550'. En cambio se clasifica como CORE si el área de la cátedra se encunetra en la siguiente lista: 'AUD', 'CGE', 'CON', 'ECO', 'FIN', 'GEP', 'GIN', 'HEC', 'IMP', 'MAC', 'MAN', 'MEC', 'MES', 'MIC', 'MKT', 'NEG', 'OPE', 'SIA', 'TAX', 'STA', 'POL', 'GES'. Y como NO CORE a los cursos cuya área sean: 'APP', 'AUS', 'CFG', 'COM', 'CSH', 'ELE', 'DEP', 'ESO', 'FEN', 'FGF', 'FOI', 'IDI', 'LEG', 'MEM', 'SEL', 'FGU', 'HAB', 'DER', 'MAT', 'LIB', 'ING', 'ESP', 'TAL'.
* __Curso_Alumnos__: Total de alumnos registrados como inscritos en el curso al momento de la consulta.

### Vista_DocentesCursos

#### Filtros

* No se registran cursos eliminados de la progrmación docente. 
* No se registran cursos con código de cátrdas antiguos, donde los útlimos 3 caractéres de su `Cod_Catedra` no son exclusivamente números. Ej: FAC0405
* Docentes solo considera a el/la o los/las profesores que hayan impartido la cátedra, no incluye ni ayudantes ni coordinadores.

#### Campos

* __Periodo__: Semestre (o Bimestre en Postgrado Executive) cuando fue o es impartida la cátedra.
* __Cod_Catedra__: Código identificador de la cátedra impartida.
* __Cod_Seccion__: Código identificador de la sección correspondiente al curso.
* __ID_Curso__: Llave única para c/curso creada para utilizarse en la construcción de relaciones en Power BI. Se genera a través de la concatenación de `Periodo`, `Cod_Catedra` y `Cod_Seccion`.
* __EvaDocente_p1p3p4__: Nota promedio de las preguntas 1,3 y 4 de la evaluación docente final, no intermedia, que obtuvo el profesor en el curso. Se cálcula promediando la media de cada una de las 3 preguntas, en escala de 1 a 7.
* __EvaDocente_p1a12__: Nota promedio de las preguntas 1 a la 12 de la evaluación docente final, no intermedia, que obtuvo el profesor en el curso. Se cálcula promediando la media de cada una de las 12 preguntas, en escala de 1 a 7.
* __EvaDocente_Nota__: Nota promedio de la evaluación realizada por los estudantes en la evaluación docente final, no intermedia, que obtuvo el profesor en el curso. La escala va de 1 a 7.
* __EvaDocente_Encuestados__: Cantidad de alumnos que respondieron la encuesta docente del curso, y cuyas evaluaciones estan registradas.
* __Carga_Academica__: Medida de carga de trabajo de un profesor en un curso específico. Generalmente, este valor a través de la operación "1/n", siendo "n" el número de profesores que imparten conjuntantmente el curso analizado. Pero, existen casos especiales como lo son con las prácticas ('ENTAL305', 'ENTAL355', 'ENTAL405', 'ENTAL500', 'ENTAL510') y Tesis, ('ENPOL850', 'ENECO853', 'ENECO851', 'ENPOL850', 'ENMKT852', 'ENMKT850', 'ENMAN851', 'ENFIN851', 'ENFIN850', 'ENECO852', 'ENECO850', 'ENCGE851', 'ENCGE850', 'ENMAN850', 'ENNEG550', 'ENECO550') cuya carga académica es asignada como igual a 0. Por otro lado, ciertos talleres ('ENTAL265', 'ENTAL260') se les asigna la mitad de carga que una cátedra normal.
<!-- Pendientes(Test) -->
## Contribuyentes

* Fernando Palomera  - [https://github.com/fdopalomera](https://github.com/fdopalomera)