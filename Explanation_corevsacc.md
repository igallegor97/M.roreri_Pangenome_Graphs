# EXPLICACIÓN DE POR QUÉ TENGO MÁS ACCESSORY QUE CORE SEGMENTS

### 1. **¿Es biológicamente plausible?**

* **Sí**. En pangenomas, el “core” normalmente se define como segmentos presentes en **todos** o “casi todos” los genomas (en tu caso, >90% = 5 de 5).
* **Accessory**: Todo lo que no es core ni exclusivo (o sea, presente en 2–4 genomas). En muchas especies, sobre todo en hongos y patógenos, el genoma accesorio puede ser muy grande, debido a duplicaciones, inserciones, elementos móviles, regiones específicas de linaje, etc.
* **Exclusive**: Solo en un genoma (la minoría).
* En hongos fitopatógenos se reportan a veces hasta **70–80% del pangenoma como accesorio**.

### 2. **¿Puede ser artefacto técnico?**

* **¡Sí!** y hay que comprobarlo:

  * *Error en parsing de paths/nodos* (ya verificaste que el script cuenta bien).
  * *Mala definición de “presencia”* (por ejemplo, pequeños fragmentos de segmentos asignados a paths).
  * *Redundancia de nodos* (el mismo segmento presente como varios nodos, o viceversa).
  * *Influencia de ensamblajes muy fragmentados* (muchos “fragmentos” únicos pueden inflar los accesorios).
  * Si tu pangenoma fue ensamblado con mucha variación estructural (SV), esperas más accesorio.
  * Si tienes **5 genomas**, cualquier segmento presente en 2, 3 o 4 se clasifica como accesorio: es un rango muy amplio.

### 3. **¿Qué impacto tiene?**

* **El downstream analysis va a mostrar muchas más regiones accessory en todos los plots**:

  * En GO, variantes, hotspots, visualización de regiones variables, etc.
  * Puede dificultar encontrar “señales” core si el accessory domina.
* **Justificación en paper**: Puedes decir:

  * “El umbral core se definió como >90% (5/5 genomas), lo que produce un core más restringido y un accessory amplio, siguiendo recomendaciones de la literatura (citar pangenoma de hongos, pangenoma en plantas, etc).”
  * “La elevada proporción de segmentos accessory podría reflejar alta variabilidad estructural entre los genomas secuenciados, ensamblados por métodos de long read.”
  * “El tamaño del core está condicionado por el bajo número de genomas: en n=5, un solo genoma faltante ya saca el segmento del core.”

### 4. **¿Cómo validar que no es error?**

* Mira el **N50 y tamaño de tus genomas**: ¿están bien ensamblados?
* Haz un plot: **histograma de cuántos segmentos aparecen en 1, 2, 3, 4, 5 genomas**.

  * Debería haber picos en 1 (exclusive), 5 (core) y muchos accessory, sobre todo si hay mucha variación.
* **Revisa la longitud de los segmentos**: ¿los accessory son mucho más cortos/fragmentados? Eso podría indicar fragmentación.
* Si tienes **genes anotados**, mira si los genes core están bien recuperados.
