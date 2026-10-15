# ==============================================================================
# Exploring the Relationship Between Metadata Features and Song Popularity
# in the Streaming Era (2014 - 2018)
#
# IJC445 - MSc Data Science, University of Sheffield
# Author: Cailey Coghlan
#
# HOW TO RUN
#   Open song-popularity-metadata-visualisation.Rproj in RStudio (this sets the
#   working directory to the repository folder), then open this file and click
#   Source. Every path below is relative to the repository folder.
#
# OUTPUTS
#   data/processed/modern_music_dataset.csv  - the combined 2014-2018 dataset
#   figures/                                 - the five figures, as PDF and PNG
#   results/                                 - the data behind each figure, as CSV
#
# Figures are numbered as in the report (docs/report.pdf).
# ==============================================================================

# Load the libraries. Install these if you don't have them before running the code:
# install.packages(c("tidyverse", "scales"))
library(tidyverse) # includes ggplot2, dplyr, readr, stringr and tidyr
library(stringr)
library(scales)
library(tidyr)

# Create the output folders if they don't exist yet.
dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
dir.create("figures", showWarnings = FALSE)
dir.create("results", showWarnings = FALSE)

# Helper: save the last plot as a high-resolution PDF (as in the report) and a PNG
# (so it displays on GitHub).
save_figure <- function(name) {
  ggsave(file.path("figures", paste0(name, ".pdf")), width = 12, height = 7, dpi = 300)
  ggsave(file.path("figures", paste0(name, ".png")), width = 12, height = 7, dpi = 150, bg = "white")
}

# **************************************************************
# PART 1. CREATING DATASET AND CLEANING
# **************************************************************

# First, load in the cleaned songs and artists datasets.
# I have named these datasets as "cleaned" because I have altered these
# by deleting columns and/or editing columns. The original MusicOSet files are
# in data/original/, and docs/FILE_GUIDE.md lists every change.

songs_cleaned <- read_csv("data/cleaned/songs_cleaned.csv", col_names = TRUE)
songs_cleaned

artists_cleaned <- read_csv("data/cleaned/artists_cleaned.csv", col_names = TRUE)
artists_cleaned

# Everything looks great with these 2 data frames.
# Now left join them together.

songs_artists_combined <- songs_cleaned %>%
  left_join(artists_cleaned, by = "artist_id")
songs_artists_combined

# Now, time to load in the cleaned acoustic features and left
# join it to songs_artists_combined.

acoustic_features_cleaned <- read_csv("data/cleaned/acoustic_features_cleaned.csv", col_names = TRUE)
acoustic_features_cleaned

songs_artists_acoustic_combined <- songs_artists_combined %>%
  left_join(acoustic_features_cleaned, by = "song_id")
songs_artists_acoustic_combined

# Now, time to load in the cleaned song pop.

song_pop_cleaned <- read_csv("data/cleaned/song_pop_cleaned.csv", col_names = TRUE)
song_pop_cleaned

# Now, left join song_pop_cleaned to songs_artists_acoustic_combined.

songs_artists_acoustic_pop_combined <- songs_artists_acoustic_combined %>%
  left_join(song_pop_cleaned, by = "song_id")
songs_artists_acoustic_pop_combined

# Now, time to load in the cleaned song chart.

song_chart_cleaned <- read_csv("data/cleaned/song_chart_cleaned.csv", col_names = TRUE)
song_chart_cleaned

# Now, left join song_chart_cleaned to songs_artists_acoustic_pop_combined.

songs_artists_acoustic_pop_chart_combined <- songs_artists_acoustic_pop_combined %>%
  left_join(song_chart_cleaned, by = "song_id")
songs_artists_acoustic_pop_chart_combined

# Now, we want to filter the dataset, using the filter() function, so that only the songs from the years 2014-2018 are shown.
# We will call this new dataset modern_music_dataset.

modern_music_dataset <- songs_artists_acoustic_pop_chart_combined %>%
  filter(year >= 2014)
modern_music_dataset

# This is our main dataset for the project, which contains 1,377 observations and 25 variables.
# Time to check that all of the variables have been correctly
# labelled by R using the glimpse() function.

glimpse(modern_music_dataset)

# R has correctly labelled all of the continuous numerical variables as dbl, the
# explicit and is_pop variables as logical and all of the categorical variables
# as character. Now, to check that there are no duplicate
# song ids using the duplicated() and sum() functions.

sum(duplicated(modern_music_dataset$song_id))

# As you can see, there are no duplicate song ids.
# Now, to check to see if there are any missing values for each variable in the dataset
# using the colSums(is.na()) function.

colSums(is.na(modern_music_dataset))

# Of importance for this project, there are 64 missing values in artist_type and
# 35 missing values in main_genre. These will be dealt with per graph, to minimize
# information loss.

# Now, to export modern_music_dataset to a table
# using write.table() function and the file will be called "modern_music_dataset.csv".

write.table(modern_music_dataset, "data/processed/modern_music_dataset.csv", sep = ",", row.names = FALSE)

# This dataset has now been saved and I can now begin creating the graphs.

# *****************************************************************************************************************
# PART 2. GENRE PREPARATION (USED BY FIGURES 1 AND 2)
# *****************************************************************************************************************

# First, since Figures 1 and 2 use the main_genre variable, we need to remove the 35 missing values using the filter() and is.na() functions.
# We will call this new dataset modern_music_genre_cleaned.

modern_music_genre_cleaned <- modern_music_dataset %>%
  filter(!is.na(main_genre))
modern_music_genre_cleaned

# Now, I'm going to create a new dataframe called modern_music_genre_grouped and I'm creating a new variable called main_genre_broad.

modern_music_genre_grouped <- modern_music_genre_cleaned %>%
  mutate(main_genre_broad = case_when(

    # Use str_detect to find any genre containing "pop" and record it as "Pop" in main_genre_broad.

    str_detect(main_genre, "pop") ~ "Pop",

    # Use str_detect to find any genre containing "hip hop, rap, or trap" and record it as "Hip Hop" in main_genre_broad.

    str_detect(main_genre, "hip hop|rap|trap") ~ "Hip Hop",

    # Use str_detect to find any genre containing "r&b" and record it as "R&B" in main_genre_broad.

    str_detect(main_genre, "r&b") ~ "R&B",

    # Use str_detect to find any genre containing "soul" and record it as "Soul" in main_genre_broad.

    str_detect(main_genre, "soul") ~ "Soul",

    # Use str_detect to find any genre containing "edm, house, electro, brostep, big room" and record it as "EDM" in main_genre_broad.

    str_detect(main_genre, "edm|house|electro|brostep|big room") ~ "EDM",

    # Use str_detect to find any genre containing "country" and record it as "Country" in main_genre_broad.

    str_detect(main_genre, "country") ~ "Country",

    # Use str_detect to find any genre containing "rock" and record it as "Rock" in main_genre_broad.

    str_detect(main_genre, "rock") ~ "Rock",

    # Use str_detect to find any genre containing "metal" and record it as "Metal" in main_genre_broad.

    str_detect(main_genre, "metal") ~ "Metal",

    # Use str_detect to find any genre containing "indie" and record it as "Indie" in main_genre_broad.

    str_detect(main_genre, "indie") ~ "Indie",

    # Use str_detect to find any genre containing "folk" and record it as "Folk" in main_genre_broad.

    str_detect(main_genre, "folk") ~ "Folk",

    # Use str_detect to find any genre containing "dance" and record it as "Dance" in main_genre_broad.

    str_detect(main_genre, "dance") ~ "Dance",

    # Keep everything else as its original title-cased name

    TRUE ~ stringr::str_to_title(main_genre)

    ))

# Now, to find the top 5 genres with the most popular songs and call the dataset top_5_popular_genres.

top_5_popular_genres <- modern_music_genre_grouped %>%
  filter(is_pop == TRUE) %>% # Filter to look only at popular songs
  count(main_genre_broad, sort = TRUE) %>%  # Count how many popular songs are in each genre
  slice_head(n = 5) # Only focus on the top 5 genres.

# View the result
print(top_5_popular_genres)
write_csv(top_5_popular_genres, "results/top_5_popular_genres.csv")

# ***************************************************************************************************************
# FIGURE 1. LOLLIPOP CHART OF TOP 5 GENRES BY PERCENTAGE OF SONGS THAT ARE POPULAR
# ***************************************************************************************************************

# 1. Prepare the Lollipop Chart Data
lollipop_data <- modern_music_genre_grouped %>% # Create a new dataset called lollipop_data based on the grouped music data.
  filter(main_genre_broad %in% top_5_popular_genres$main_genre_broad) %>% # Keep only the genres that were identified as being in the top 5 most popular.
  group_by(main_genre_broad) %>% # Group the data by the broad genre name for summary calculations.
  summarise(total_songs = n(), pop_count = sum(is_pop == TRUE, na.rm = TRUE), # Count the total number of songs in each genre. Sum the number of popular songs, ignoring missing values
  success_rate = pop_count / total_songs, .groups = 'drop') # Divide popular songs by total to get the success percentage and then remove the grouping.
lollipop_data
write_csv(lollipop_data, "results/fig1_genre_popularity_rate.csv")

# 2. Create the Lollipop Chart
ggplot(lollipop_data, aes(x = reorder(main_genre_broad, success_rate), y = success_rate)) + # Initialize the ggplot object, ordering the Genre axis by the success rate value.
  geom_segment(aes(x = reorder(main_genre_broad, success_rate), xend = reorder(main_genre_broad, success_rate), y = 0, yend = success_rate, linewidth = success_rate), color = "grey50") + # Draw the "sticks" of the lollipops using line segments
  scale_linewidth_continuous(range = c(1, 2.5), guide = "none") + # Set the thickness range for the sticks and remove the legend for line width.
  geom_point(aes(fill = success_rate, size = success_rate), shape = 21, color = "grey40", stroke = 1) + # Draw the "heads" of the lollipops.
  scale_size_continuous(range = c(10, 16), guide = "none") + # Set the size range for the heads and remove the legend for the heads.
  geom_text(aes(label = scales::percent(success_rate, accuracy = 1)), color = "black", fontface = "bold", # Add the percentage labels to the right of the heads and selects their font and size.
  size = 6, family = "sans", hjust = -0.6) +
  scale_fill_gradient(low = "#bcd2ee", high = "#0072B2", labels = scales::percent_format(accuracy = 1), name = "Popularity Rate (%)", # Define the color gradient for the heads fill and label the legend.
  guide = guide_colorbar(barheight = unit(6, "cm"), barwidth = unit(0.5, "cm"))) + # Size of the legend bar.
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = seq(0, 0.5, by = 0.1), limits = c(-0.03, 0.50)) + # Configure the Y-axis (which will be the horizontal axis after coord_flip).
  coord_flip() +
  labs(title = "Popularity Rate of the Top 5 Most Popular Genres (2014 - 2018)", subtitle = "", x = "Genre", y = "Popularity Rate (%)") + # Title and labeling of the x-axis and y-axis.
  theme_minimal(base_size = 18) + #Theme below to match the other graphs.
  theme(text = element_text(family = "sans", lineheight = 1.2),
      plot.title = element_text(face = "bold", size = 22, hjust = 0.5, margin = margin(b = 10)),
      plot.subtitle = element_text(face = "italic", size = 15, hjust = 0.5, margin = margin(b = 20)),
      axis.title = element_text(face = "bold", size = 16),
      axis.text = element_text(color = "black", size = 14),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank(),
      legend.title = element_text(face = "bold", size = 14),
      legend.text = element_text(face = "bold", size = 12),
      plot.margin = margin(10, 20, 10, 10))

# 3. Exporting to PDF with dpi = 300 for high resolution (and PNG for GitHub).
save_figure("fig1_lollipop_genre_popularity")

# *****************************************************************************************************************
# FIGURE 2. HEAT MAP OF TOP 5 MOST POPULAR GENRES AND THEIR SONG TYPES AND COLOURED BY PERCENTAGE OF POPULAR SONGS
# *****************************************************************************************************************

# 1. Prepare Heat Map Data
heatmap_success_data <- modern_music_genre_grouped %>%
  filter(main_genre_broad %in% top_5_popular_genres$main_genre_broad) %>% # Only select top 5 most popular genres.
  group_by(main_genre_broad, song_type) %>% # Group by main_genre_broad and song_type.
  summarise(total_songs = n(), # Count total songs in group
  pop_count = sum(is_pop == TRUE), # Count popular songs in group
  success_rate = pop_count / total_songs, # Calculate percentage
  .groups = 'drop') %>% # Un-group for further steps
  tidyr::complete(main_genre_broad, song_type) %>% # Ensures all Genre/Song Type combinations exist (adds NAs for missing data)
  mutate(success_rate = ifelse(success_rate == 0, NA, success_rate)) # Convert success_rate of 0 to NA so it triggers the grey box and "No Data" label
heatmap_success_data
write_csv(heatmap_success_data, "results/fig2_genre_by_song_type_popularity_rate.csv")

# 2. Create The Heat map
ggplot(heatmap_success_data, aes(x = song_type, y = reorder(main_genre_broad, success_rate, FUN = mean, na.rm = TRUE), fill = success_rate)) + # Reorder Y-axis genres by their average success rate.
  geom_tile(color = "white", linewidth = 0.8) + # Draw the heatmap tiles with a white border and certain width.
  geom_text(aes(label = ifelse(is.na(success_rate), "No Data", scales::percent(success_rate, accuracy = 1)), # Add text labels inside the tiles. Add label "No Data" for tiles that contain no data.
  color = ifelse(is.na(success_rate) | success_rate < 0.4, "black", "white")), fontface = "bold", size = 5, family = "sans") + # Use white text on dark tiles, black on light/grey tiles. Size 5 sans-serif font and bold.
  scale_fill_gradient(low = "#f7fbff", high = "#0072B2", na.value = "grey90", labels = scales::percent_format(accuracy = 1), name = "Popularity Rate (%)", # Define the blue color gradient and legend scale colours and giving the legend a title.
  guide = guide_colorbar(barheight = unit(6, "cm"), barwidth = unit(0.5, "cm"))) +
  scale_color_identity() + # Ensure the black/white text colors are applied. # Labelling the x-axis and y-axis and giving the graph a title and subtitle.
  labs(title = "Top 5 Most Popular Genres by Their Song Types (2014 - 2018)",
  subtitle = "Percentage of Songs Reaching 'Popular' Status Within Each Genre", x = "Song Type", y = "Genre") +
  theme_minimal(base_size = 18) + # Apply a clean theme and set base font size.
  # Detailed theme adjustments below for visual polish.
  theme(text = element_text(family = "sans"),
      plot.title = element_text(face = "bold", size = 22, margin = margin(b = 10), hjust = 0.5),
      plot.subtitle = element_text(face = "italic", size = 15, margin = margin(b = 20), hjust = 0.5),
      axis.title = element_text(face = "bold", size = 16),
      axis.text = element_text(color = "black", size = 14),
      panel.grid = element_blank(),
      legend.title = element_text(face = "bold", size = 14),
      legend.text = element_text(face = "bold", size = 12), # Bolding numeric values
      legend.position = "right",
      legend.margin = margin(l = 10),
      plot.margin = margin(10, 20, 10, 10))

# 3. Exporting to PDF with dpi = 300 for high resolution (and PNG for GitHub).
save_figure("fig2_heatmap_genre_song_type")

# ***************************************************************************************************************
# FIGURE 3. GROUPED BAR CHART OF EXPLICIT VS CLEAN SONGS BY POPULARITY
# ***************************************************************************************************************

# 1. Prepare the Grouped Bar Chart Data
grouped_bar_explicit_data <- modern_music_dataset %>% # Create a new dataset for the grouped bar chart.
  count(explicit, is_pop) %>% # Counts the number of occurrences for every combination of explicit and is_pop.
  group_by(explicit) %>% # Tells R to perform the next calculations separately for explicit and clean songs.
  mutate(percentage = round((n / sum(n)) * 100, 0)) %>% # calculates the percentage of popular and not popular songs within each explicitness category and rounds the percentage to the nearest whole number.
  ungroup() %>%
  mutate(explicit = reorder(explicit, percentage * (is_pop == TRUE))) # Reorders the dataset based on the percentage of popular songs.
grouped_bar_explicit_data
write_csv(grouped_bar_explicit_data, "results/fig3_explicit_vs_clean_popularity.csv")

# 2. Create the Grouped Bar Chart
ggplot(grouped_bar_explicit_data, aes(x = percentage, y = explicit, fill = as.factor(is_pop))) + # Initializes the plot, mapping percentages to the X-axis, explicitness to the Y-axis, and using popularity to determine the bar colors.
  geom_col(position = position_dodge(width = 0.8), width = 0.7) + # Draws the bars. position_dodge() places the bars side-by-side rather than stacked.
  geom_text(aes(label = paste0(percentage, "%")), position = position_dodge(width = 0.8), hjust = -0.3, fontface = "bold", size = 5, family = "sans") + # Adds the text labels (e.g., "33%") to the bars. Also, the font type, size, and positioning.
  scale_y_discrete(labels = c("TRUE" = "Explicit", "FALSE" = "Clean")) + # Renames the Y-axis categories from logical TRUE/FALSE to more readable "Explicit" and "Clean".
  scale_fill_manual(values = c("TRUE" = "#0072B2", "FALSE" = "#D55E00"), labels = c("TRUE" = "Popular", "FALSE" = "Not Popular")) + # Manually assigns specific colors to the bars(blue and orange) and renames the legend items to "Popular" and "Not Popular".
  scale_x_continuous(breaks = seq(0, 100, by = 10), limits = c(0, 100), expand = expansion(mult = c(0, 0.05))) + # Sets the X-axis to run from 0 to 100, with tick marks every 10 units.
  labs(title = "Clean Vs. Explicit Music by Popularity (2014 - 2018)", subtitle = "", x = "Percentage of Songs (%)", y = "Explicitness", fill = "") + # Sets the title, axis labels, and removes the legend title (empty string).
  theme_bw(base_size = 18) + # Theme below to match the other graphs.
  theme(text = element_text(family = "sans"),
        plot.background = element_rect(fill = "white", color = NA),
        panel.background = element_rect(fill = "white", color = NA),
        panel.border = element_blank(),
        axis.line = element_line(color = "black"),
        plot.title = element_text(face = "bold", size = 22, margin = margin(b = 10), hjust = 0.5),
        plot.subtitle = element_text(face = "italic", size = 15, margin = margin(b = 20), hjust = 0.5),
        axis.title.y = element_text(face = "bold", size = 16, margin = margin(r = 15)),
        axis.title.x = element_text(face = "bold", size = 16, margin = margin(t = 15)),
        axis.text = element_text(face = "plain", size = 12, color = "black"),
        legend.position = "top",
        legend.justification = "center",
        legend.direction = "horizontal",
        legend.margin = margin(t = 0, b = 10),
        panel.grid.major = element_line(color = "grey92"),
        panel.grid.minor = element_blank())

# 3. Exporting to PDF with dpi = 300 for high resolution (and PNG for GitHub).
save_figure("fig3_bar_explicit_popularity")

# **********************************************************************************
# FIGURE 4. LINE CHART FOR PERCENTAGE OF SONGS THAT ARE EXPLICIT OR CLEAN BY YEAR
# **********************************************************************************

# 1. Prepare the Line Chart Data
line_chart_1_data <- modern_music_dataset %>% # Creating a new dataset for the line chart.
  group_by(year, explicit) %>% # Organizes the data into buckets based on the year and whether the song is explicit or clean.
  summarise(count = n(), .groups = 'drop_last') %>% # Counts the number of songs in each bucket; .groups = 'drop_last' keeps the data grouped by year but drops the explicit group.
  mutate(percentage = round((count / sum(count)) * 100, 0)) %>% # Within each year, it calculates the percentage of songs that are explicit vs. clean and rounds to the nearest whole number.
  ungroup()
line_chart_1_data
write_csv(line_chart_1_data, "results/fig4_explicit_share_by_year.csv")

# 2. Creating the Line Chart
ggplot(line_chart_1_data, aes(x = year, y = percentage, color = explicit, linetype = explicit, shape = explicit)) + # It maps year to the horizontal axis, percentage to the vertical, and uses the explicit status to determine colors, line styles, and point shapes.
  geom_line(linewidth = 1.2) + # Draws the trend lines with a slightly thicker width for better visibility.
  geom_point(size = 3) + # Adds markers at each yearly data point to help the viewer pinpoint the exact percentage.
  geom_text(data = line_chart_1_data %>% group_by(explicit) %>% filter(percentage == max(percentage)), aes(label = paste0(percentage, "%")), vjust = -1.0, fontface = "bold", size = 5, show.legend = FALSE, family = "sans") + # This filters the data to find the highest percentage point for both clean and explicit songs and places a bold percentage label above those peaks.
  geom_text(data = line_chart_1_data %>% filter(year == 2018), aes(label = ifelse(explicit == TRUE, "Explicit", "Clean")), hjust = -0.15, fontface = "bold", size = 5.5, show.legend = FALSE, family = "sans") + # This looks only at the final year (2018) and adds the text "Explicit" or "Clean" next to the end of the lines.
  scale_color_manual(values = c("TRUE" = "#D55E00", "FALSE" = "#0072B2")) + # Manually sets the colors for the lines (orange for Explicit, blue for Clean).
  scale_linetype_manual(values = c("TRUE" = "solid", "FALSE" = "dashed")) + # Makes the "Clean" line dashed and the "Explicit" line solid to make them distinguishable even for colorblind readers.
  scale_shape_manual(values = c("TRUE" = 16, "FALSE" = 17)) + # Assigns a circle (16) to Explicit and a triangle (17) to Clean points.
  scale_x_continuous(breaks = c(2014, 2015, 2016, 2017, 2018), expand = expansion(mult = c(0.05, 0.2))) + # Forces the X-axis to show every year and adds extra space on the right (0.2) to fit the "Explicit/Clean" text labels.
  scale_y_continuous(limits = c(0, 115), breaks = seq(0, 100, by = 10), expand = c(0, 0)) + # Sets the Y-axis from 0 to 115% (giving headroom for labels) and ensures the axis starts exactly at zero.
  labs(title = "Trends in Explicit Vs. Clean Music (2014 - 2018)", subtitle = "Peak Percentages Labeled for Quick Reference", x = "Year", y = "Percentage of Songs (%)") + # Provides the main title, italicized subtitle, and clear axis titles.
  theme_bw(base_size = 18) + # Theme below to match the other graphs.
  theme(text = element_text(family = "sans"),
        plot.title = element_text(face = "bold", size = 22, margin = margin(b = 10), hjust = 0.5),
        plot.subtitle = element_text(face = "italic", size = 15, margin = margin(b = 20), hjust = 0.5),
        axis.title.y = element_text(face = "bold", size = 16, margin = margin(r = 15)),
        axis.title.x = element_text(face = "bold", size = 16, margin = margin(t = 15)),
        axis.text = element_text(face = "plain", size = 12, color = "black"),
        legend.position = "none",
        panel.grid.major = element_line(color = "grey92"),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        axis.line = element_line(color = "black"))

# 3. Exporting to PDF with dpi = 300 for high resolution (and PNG for GitHub).
save_figure("fig4_line_explicit_trend")

# ****************************************************************************************************
# FIGURE 5. GROUPED BAR CHART FOR ARTIST TYPE BY POPULARITY
# ****************************************************************************************************

# 1. Clean Data
modern_music_artist_type_cleaned <- modern_music_dataset %>%
  filter(!is.na(artist_type)) # Removing all the missing values for artist type.

# 2. Prepare the Grouped Bar Chart Data
grouped_bar_artist_data <- modern_music_artist_type_cleaned %>%
  count(artist_type, is_pop) %>% # Counts how many songs belong to each artist type and whether they are popular or not.
  group_by(artist_type) %>% # Groups the data so the next percentage calculation happens within each artist category.
  mutate(percentage = round((n / sum(n)) * 100, 0), artist_type = stringr::str_to_title(artist_type), artist_type = ifelse(artist_type == "Dj", "DJ", artist_type)) %>% # Calculates the percentage of popular vs. not popular songs. Converts text to "Title Case" (e.g., "solo" becomes "Solo"). Specifically fixes the capitalization of "DJ" so it's not "Dj".
  ungroup() %>%
  mutate(artist_type = reorder(artist_type, percentage * (is_pop == TRUE))) # Sorts the dataset, so the artist type with the highest percentage of "Popular" songs appears at the top.
grouped_bar_artist_data
write_csv(grouped_bar_artist_data, "results/fig5_artist_type_popularity.csv")

# 3. Create the Grouped Bar Chart
ggplot(grouped_bar_artist_data, aes(x = percentage, y = artist_type, fill = as.factor(is_pop))) + # Maps percentages to the X-axis, artist type to the Y-axis, and popularity to the color of the bars.
  geom_col(position = position_dodge(width = 0.8), width = 0.7) + # Creates the bars (side-by-side) instead of stacked ones.
  geom_text(aes(label = paste0(percentage, "%")), position = position_dodge(width = 0.8), hjust = -0.3, fontface = "bold", size = 5, family = "sans") + # Ensures the text labels align with the center of each individual bar.
  scale_fill_manual(values = c("TRUE" = "#0072B2", "FALSE" = "#D55E00"), labels = c("TRUE" = "Popular", "FALSE" = "Not Popular")) + # Uses a colorblind-friendly palette (Blue/Orange) and sets the labels for the legend.
  scale_x_continuous(breaks = seq(0, 100, by = 10), limits = c(0, 110), expand = expansion(mult = c(0, 0.05))) + # Sets the scale from 0 to 110 (the extra 10 provides space for the text labels so they aren't cut off).
  labs(title = "Artist Types By Popularity (2014 - 2018)", subtitle = "", x = "Percentage of Songs (%)", y = "Artist Type", fill = "") + # Defines the title, subtitle, and axis names.
  theme_bw(base_size = 18) + # Theme below to match the other graphs.
  theme(text = element_text(family = "sans"),
        plot.background = element_rect(fill = "white", color = NA),
        panel.background = element_rect(fill = "white", color = NA),
        panel.border = element_blank(),
        axis.line = element_line(color = "black"),
        plot.title = element_text(face = "bold", size = 22, margin = margin(b = 10), hjust = 0.5),
        plot.subtitle = element_text(face = "italic", size = 15, margin = margin(b = 20), hjust = 0.5),
        axis.title.y = element_text(face = "bold", size = 16, margin = margin(r = 15)),
        axis.title.x = element_text(face = "bold", size = 16, margin = margin(t = 15)),
        axis.text = element_text(face = "plain", size = 12, color = "black"),
        legend.position = "top",
        legend.justification = "center",
        legend.direction = "horizontal",
        legend.margin = margin(t = 0, b = 10),
        panel.grid.major = element_line(color = "grey92"),
        panel.grid.minor = element_blank())

# 4. Exporting to PDF with dpi = 300 for high resolution (and PNG for GitHub).
save_figure("fig5_bar_artist_type")
