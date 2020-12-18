# Predicting-Youtube-Video-Growth-Rate
growth rate between 2 to 6 hours
We achieve a R-squared of 70%. There are still rooms for improvement, such as finding more way to extract the information from the time variable.
Below is the description of this dataset.

The training data are in the file training.csv. In the dataset, each row corresponds to a YouTube video and each column to a feature of the video. The dataset includes 7242 videos and 258 predictors, generally falling into one of four categories: thumbnail image features (for example, percent of nonzero pixels), video title features (for example, number of words in title), channel features (for example, number of subscribers to the channel), and other features (for example, video duration). A detailed description of all features can be found in the file 'Feature_Descriptions.xlsx'.

This training data also includes the response variable called 'growth_2_6' which measures the percent change in views between the second and sixth hour since the video was published. For example, if a video has 100 views at the second hour, and 1000 views at the sixth hour, the percent change is 900% so 'growth_2_6' will be 9.0. Note that 'growth_2_6' for the train and test data is bounded between 0 and 10. The id column in this dataset identifies each observation in the training data.

The test data are in file test.csv. The dataset includes 3105 videos and 258 predictors. The test data does not include the 'growth_2_6' column. The challenge is to closely predict the true value of 'growth_2_6' in this dataset. The id column in this dataset identifies each observation in the test data. To avoid confusions, the values in the id column in the test.csv file are different from those in the training.csv file.

An example of a correct submission file is in sample.csv. The file must contain two columns labeled id and 'growth_2_6'. The values in the id column in the submission file must match those of the corresponding column in the test.csv file. In the submission file, the 'growth_2_6' column must contain the predicted growth rates obtained using your model for each video in the test data. The values in this 'growth_2_6' column must be numeric. The submission file must not include the predictor columns.
