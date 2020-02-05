# SPRINT_analysis
SPRINT (Spatial Pseudotime Ranking in Tissues)is a tool that spatially maps pseudotemporal trajectories at single-cell resolution in situ with a simple computational workflow and single-round fluorescent imaging.

SPRINT involves three major steps: (i) computational analysis of a scRNA-seq dataset from your tissue of interest to select features (i.e., genes) whose expressions significantly co-vary with cell state transitions. It then assigns each of such genes to an imaging channel; (ii) a tissue preparation and imaging step that probes the abundance of selected genes in situ by capturing the integrated fluorescence intensities within each cell. (iii) a post-imaging analysis step that uses the information from (ii) to reconstruct a trajectory of cell state transitions in situ.

Before using SPRINT, users need to provide a scRNA-seq dataset. Multiple datasets on the same tissue can be used to select for a gene list that yields the best reference distribution. Once having the scRNA-seq dataset, users need to run a publicly availabe pseudotime analysis tool (e.g., Monocle) to assign pseudotime values to each cells in the dataset. SPRINT is compatible with any pseudotime analysis tool that assigns each cell in the dataset a uniqe pseudotime value. Users are encouraged to try different tools to generate a pseudotime ranking on their scRNA-seq that makes the most biological sense. 

With those information at hand, uers can run the Jupyter Notebook entitled 'Pseudotime_to_probe_workflow.ipynb' to generate a reference distribution, a list of selected genes and HCR probe sequences for those genes. Alternatively, once having the list of genes, users can also run the Matlab code 'SplintRHomologyGenBetterBlastHCR.m' which ouputs the same HCR probe sequences for those genes. 

After obtaining the HCR images, users can segment the images using the CellProfiler pipeline 'Image_segmentation_pipeline.cpproj'. It is noted that this pipeline offers a starting point for the image segmentation. Users may need to perform customization for their own images. The image analysis pipline outputs a csv file (referred to as the intensity distribution file) that contains for each segmented cell, the spatial coordiantes, integrated intensity for each imaging channel along with other properties. It also outputs a color image for the segmented cell mask. The file and the image will be used to reconstruct pseudotime trajectories in situ in the following steps. 

Next, the Jupyte Notebook entitled 'Mapping.ipynb' takes the reference distribution and the intensity distribution files and returns the mapped pseudotime value for each segmented cell from the HCR image. 


