# Datasets
Datasets used for both the LBLR and AutoLBLR experiments.

## Dataset Format
Each dataset file should have the `.mat` extension and should contain a single structure with the following fields: "Information" "TimeSeries" "Solution"
```
SampleDataset = 
  struct with fields:

        Information: "This dataset serves as an example"  <- Information pertaining to the dataset (can be empty)
         TimeSeries: [n×1 double]                         <- Numerical, non-empty, column vector of length n
           Solution: [n×1 double]                         <- Integer column vector of length n (can be empty)
```