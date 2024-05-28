# STCA Dataset
Welcome to the STCA Dataset repository.
We collect public datasets about the entry of asylum seekers into Canada from multiple departments of the Government of Canada.
These data will be released under the _HAVEN: Asylum Lab_ project for public usage.

## Using the Data
We have the cleaned data in `.csv` and `.rds` file format under the `data/clean/` directory.
Accompanying metadata are available for each table and sub-dataset.
To access the complete metadata, check out `data/master_doc_compressed.pdf`.

## Reproduce the Cleaned Data
### Data Source
The raw data files are located under the `data/raw/` directory.
Manifests are available for each raw file which includes the source URL.

### Processing the Source
**Requirements**:
- A working installation of [R](https://www.r-project.org/) (tested on `R-4.4.0` on Windows 11)
  - If you don't have it in your environment, install the `tidyverse` package by running `install.packages("tidyverse")` in the R console
- Any `.xlsx` and `.csv` editor

Scripts under the `R/` directory will parse the source webpage files in `data/raw/web_ircc/` and `data/raw/web_rad/` and output the cleaned tables to `data/clean/ircc/` and `data/clean/rad/` directories respectively.
IRB Irregular crossers claims data (`data/clean/quarterly_irregular_claims/`) are edited manually using a spreadsheet editor, for instructions check the "Modules" section in the complete metadata.

### Generating the Metadata Document
**Requirements**:
- A working installation of [Typst](https://typst.app/) (tested on `typst-0.11.1` on Windows 11)
- A working installation of [Ghostscript](https://ghostscript.com/index.html) (optional, tested on `ghostscript-10.03.1` on Windows 11)
- A working shell on this repo's root directory. Make sure to run the commands below using the right path.

The individual `.csv` metadata for each table/sub-dataset are manually generated.
To generate the complete metadata document (`data/master_doc.pdf`), run the following command:
```
typst compile data/master_doc.typ
```
This will read all the individual metadata and compile it into a single human-readable document.

OPTIONAL: Compress `data/master_doc.pdf` for distribution by running the following command:
```
ghostscript -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER -dPDFSettings=/screen -sOutputFile="data/master_doc_compressed.pdf" "data/master_doc.pdf"
```
