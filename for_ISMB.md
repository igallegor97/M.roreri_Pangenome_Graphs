# Visualización e Interpretación del Pangenoma de *Moniliophthora roreri* para ISMB 2025

Este documento resume las visualizaciones clave y resultados recomendados para presentar en ISMB 2025 a partir del pangenoma construido con **Cactus minigraph** y visualizado con **SequenceTubeMap**.

---

## 📌 Resumen de Resultados del Pangenoma

- **Genomas analizados**: 5 cepas de *M. roreri* secuenciadas con PacBio.
- **Metodología**:
  - Construcción de pangenoma con Cactus Minigraph.
  - Visualización de grafos con SequenceTubeMap.
  - Análisis estructural y de variantes con VG toolkit.

### 📊 Estadísticas generales sugeridas para presentar

- Tamaño total del pangenoma vs. tamaño promedio de los genomas individuales.
- Número total de genes:
  - Genes **core** (presentes en todos).
  - Genes **accesorios** (presentes en varios).
  - Genes **únicos** (presentes en uno solo).
- Porcentaje de contenido genético compartido vs. exclusivo por muestra.
- Número y tipos de variantes estructurales identificadas (SNPs, indels, inserciones, duplicaciones, etc).

---

## 🔍 Regiones sugeridas para visualizar en STM

### 1. Regiones **altamente variables**
- Visualizar diferencias estructurales como grandes inserciones o deleciones entre cepas.
- Ejemplo: regiones donde solo una cepa sigue un camino alternativo.

### 2. Regiones **con variantes puntuales**
- Mostrar segmentos donde hay SNPs o indels sobre un fondo de conservación estructural.

### 3. Loci **biológicamente relevantes**
- Genes asociados a virulencia, adaptación o resistencia si se dispone de anotación funcional.
- Mostrar cómo estos genes están presentes/ausentes o varían entre cepas.

### 4. Regiones con **presencia/ausencia** de genes
- Visualizar tracks donde se observe claramente que algunos paths incluyen genes y otros no.

---

## 🧬 Integración de Estadísticas de Variantes

Los análisis de variantes pueden enriquecer la narrativa de la presentación:

- Mapas de **densidad de variantes** a lo largo del pangenoma.
- Comparaciones de variantes estructurales por región y por cepa.
- Asociación de regiones con alta variabilidad con posibles funciones adaptativas.

### Integraciones posibles:

| Datos de variantes | Integración en visualización |
|--------------------|------------------------------|
| SNPs / indels      | Marcar regiones con alta densidad de variantes en STM. |
| Variantes estructurales | Mostrar ejemplos claros de inserciones/deleciones únicas. |
| Genes variantes    | Asociar cambios genéticos a funciones anotadas o fenotipos. |

---

## 🎨 Visualizaciones recomendadas para la presentación

- Capturas de pantalla o videos desde SequenceTubeMap:
  - Comparaciones de paths por región y cepa.
  - Regiones con estructura variable.

- Gráficos adicionales:
  - Diagrama de Upset o Venn de genes core/accesorios/únicos.
  - Heatmap de presencia/ausencia de genes por cepa.
  - Gráfico de barras del número de variantes por tipo y por cepa.

---

## 🧠 Discusión Biológica Sugerida

- ¿Qué significan las diferencias estructurales observadas?
- ¿Hay indicios de adaptación local?
- ¿Hay correlación entre contenido genético y grupos geográficos o fenotípicos?
- ¿Algún grupo tiene mayor proporción de contenido accesorio?
- ¿Qué genes o regiones merecen análisis funcional más profundo?

---

## 🚀 Próximos pasos

- Integrar anotación funcional a los genes presentes en regiones accesorias.
- Realizar enriquecimiento GO/Pfam para genes exclusivos.
- Relacionar presencia/ausencia con metadatos fenotípicos (si disponibles).
- Ampliar el análisis con más cepas o ensamblajes alternativos.

---

**Autora:** Isabella Gallego Rendón  
**Proyecto:** Análisis del Pangenoma de *M. roreri*  
**Evento:** ISMB 2025  
**Visualización:** SequenceTubeMap  
**Pangenoma:** Cactus Minigraph  
