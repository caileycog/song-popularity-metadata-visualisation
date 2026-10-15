# File guide

What every file in this repository is, how they fit together, and how the original data was cleaned.

## Top level

| File | What it is |
|---|---|
| `README.md` | Project summary, the five figures, design decisions, data preparation, limitations and how to run. |
| `song-popularity-metadata-visualisation.Rproj` | RStudio project file. Opening it sets the working directory to this folder, so every file path in the code works. |
| `.gitignore` | Keeps RStudio's temporary files (`.Rhistory`, `.RData`, `.Rproj.user/`) and system files out of the repository. |

## `R/`

| File | What it is |
|---|---|
| `data_visualisation.R` | The full analysis. Open the `.Rproj` file, then open this script and click **Source**. |

The script runs in three parts:

1. **Creating the dataset.** It reads the five cleaned tables, left-joins them on `song_id` and `artist_id`, and filters to 2014–2018 (1,377 songs × 25 variables). It then checks for duplicate songs and missing values, and saves the result to `data/processed/modern_music_dataset.csv`.
2. **Genre preparation.** It drops the 35 songs with no genre, groups the 120 detailed genres into broad families with `str_detect()`, and finds the five genres with the most popular songs.
3. **Figures 1–5.** Each figure has the same three steps: prepare a summary table, build the chart in ggplot2, and save it to `figures/` as a 300 dpi PDF and a PNG. Each summary table is also saved to `results/`. The 64 songs with no artist type are dropped only for Figure 5.

The figures are numbered as in the report.

## `data/`

### `data/original/`
The five MusicOSet tables, as downloaded from [marianaossilva.github.io/DSW2019](https://marianaossilva.github.io/DSW2019/) and saved as comma-separated files.

| File | Rows | What it contains |
|---|---|---|
| `songs_original.csv` | 20,405 | One row per song: name, Billboard credit, Spotify artists, popularity, explicit flag, song type (solo or collaboration). |
| `artists_original.csv` | 11,518 | One row per artist: name, followers, popularity, artist type, main genre, all genres, image URL. |
| `acoustic_features_original.csv` | 20,405 | Spotify audio features per song: duration, key, mode, tempo, energy, danceability, valence and others. |
| `song_pop_original.csv` | 25,193 | One row per song per year: year-end score and `is_pop` (whether the song made the year-end chart). |
| `song_chart_original.csv` | 250,392 | One row per song per week on the Billboard Hot 100: rank score, peak position, weeks on chart. |

### `data/cleaned/`
The five tables the code reads. The changes from the originals are listed below.

### `data/processed/`
| File | What it is |
|---|---|
| `modern_music_dataset.csv` | The combined analysis dataset: 1,377 songs from 2014–2018 with 25 variables. The code creates it. |

## How the original files were cleaned

The cleaning was done before the R analysis. Comparing each cleaned table with its original shows these changes:

| Table | Changes |
|---|---|
| **songs** | Removed `billboard`, `artists` and `popularity`. Added `artist` (the Billboard artist credit), `artist_updated` (the lead, first-credited artist) and `artist_id` (that artist's Spotify ID), so that each song links to one artist. A few artist names were matched by hand where the Billboard spelling differs from Spotify's (for example "Musiq" → "Musiq Soulchild"). |
| **artists** | Kept `artist_id`, `followers` (renamed `artist_followers`), `artist_type` and `main_genre`, and removed the rest. Placeholder `-` values in artist type and main genre were set to missing. Hyphens were removed from genre names (for example "k-pop" → "kpop"). The two artists with no follower count were given 0. |
| **acoustic features** | Removed `key` and `mode`. |
| **song popularity** | Reduced to one row per song, keeping the song's first year in the year-end data and its `is_pop` value for that year. Removed `year_end_score`. |
| **song chart** | Reduced to one row per song, keeping its best (lowest) peak position and its longest run in weeks on the chart. Removed `rank_score` and `week`. |

## `figures/`

| File | Figure in the report |
|---|---|
| `fig1_lollipop_genre_popularity` | Figure 1: popularity rate of the top 5 genres (lollipop chart) |
| `fig2_heatmap_genre_song_type` | Figure 2: popularity rate by genre and song type (heat map) |
| `fig3_bar_explicit_popularity` | Figure 3: clean vs explicit songs by popularity (grouped bar chart) |
| `fig4_line_explicit_trend` | Figure 4: share of explicit and clean songs by year (line chart) |
| `fig5_bar_artist_type` | Figure 5: artist type by popularity (grouped bar chart) |

Each figure is saved twice. The `.pdf` is the 300 dpi version used in the report, and the `.png` is the version displayed in the README.

## `results/`

The summary table behind each figure, as CSV.

| File | What it contains |
|---|---|
| `top_5_popular_genres.csv` | The five genres with the most popular songs, which are the genres used in Figures 1 and 2. |
| `fig1_genre_popularity_rate.csv` | Total songs, popular songs and popularity rate for each of the top 5 genres. |
| `fig2_genre_by_song_type_popularity_rate.csv` | The same figures split by solo and collaboration. Empty rows are combinations with no songs (or a 0% rate), shown as "No Data". |
| `fig3_explicit_vs_clean_popularity.csv` | Counts and percentages of popular and non-popular songs, for clean and explicit songs. |
| `fig4_explicit_share_by_year.csv` | Number and percentage of explicit and clean songs in each year from 2014 to 2018. |
| `fig5_artist_type_popularity.csv` | Counts and percentages of popular and non-popular songs for each artist type. |

## `docs/`

| File | What it is |
|---|---|
| `report.pdf` | The full report. Sections: the composite visualisation and findings (Knowledge Building), Theoretical Frameworks, Accessibility, Visualisation Choice, and Implications and Improvements. The appendix contains the R code. |
| `FILE_GUIDE.md` | This file. |

## How the files connect

```
data/original/*.csv ──(cleaning, listed above)──► data/cleaned/*.csv
                                                        │
                                                        ▼
                                          R/data_visualisation.R
                                     ┌──────────────┼──────────────┐
                                     ▼              ▼              ▼
              data/processed/modern_music_dataset.csv  figures/  results/
```
