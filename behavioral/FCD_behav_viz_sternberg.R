# FCD behavioral data visualizations

# Setup ----------------------------------------------------------------------------------------------------------------------------------
pacman::p_load(tidyverse, 
               janitor,  # tidy data easily
               patchwork # assemble graphs
)

# Load FCD data
dat <- read.csv("/Volumes/methlab/Students/Arne/PhD Courses/Courses UZH/24HS_Data_Visualization/exercises/data/fcd_behavioral_data.csv")

# Change variable types
dat$ID <- as.integer(dat$ID)                      # ID as integer
dat$Trial <- as.integer(dat$Trial)                # Trial as integer
dat$Condition <- as.factor(dat$Condition)         # Condition as factor
dat$Accuracy <- as.integer(dat$Accuracy)          # Accuracy as numeric
dat$ReactionTime <- as.numeric(dat$ReactionTime)  # ReactionTime as numeric
dat$Stimuli <- as.character(dat$Stimuli)          # Stimuli as character
dat$Probe <- as.character(dat$Probe)              # Probe as character
dat$Match <- as.integer(dat$Match)                # Match as integer

# Define color palette
# pal <- c("#FF8C00", "#A034F0", "#159090")
# pal <- c("#ADD8E6", "#D3D3D3", "#FFC0CB") # Pastel blue, pastel black (grey), pastel red
# pal <- c("#4682B4", "#696969", "#CD5C5C") # Darker blue, darker grey, darker red
pal <- c("#0D4F8B", "#1C1C1C", "#8B0000") # Very dark blue, very dark grey, very dark red

## REACTION TIME trial by trial  with RAINPLOT  ------------------------------------------------------------------------------------
# Transform reaction times to milliseconds
dat$ReactionTime <- dat$ReactionTime * 1000

# Precompute sample sizes
sample_sizes <- dat |> 
  group_by(Condition) |> 
  summarise(n = n(), .groups = "drop")

# Rainplot
dat |> 
  group_by(Condition) |> 
  # Define data to plot
  ggplot(aes(x = ReactionTime, y = Condition)) + 
  ggdist::stat_halfeye(
    aes(color = Condition,
        fill = after_scale(lighten(color, .5))),
    adjust = .5,
    width = .5,
    height = .6,
    .width = 0, # Keep at 0 to remove middle line along data
    justification = -.4,
    point_color = NA
  ) +
  # Boxplot
  geom_boxplot(
    aes(color = stage(Condition, after_scale = darken(color, .1, space = "HLS")),
        fill = after_scale(desaturate(lighten(color, .8), .4))),
    width = .35, 
    outlier.shape = NA
  ) +
  # Display data points with jitter on y-axis
  geom_point(
    aes(color = stage(Condition, after_scale = darken(color, .1, space = "HLS"))),
    fill = "white",
    shape = 21,
    stroke = .4,
    size = .5,
    position = position_jitter(seed = 1, height = 0.125),
    alpha = .4
  ) +
  geom_point(
    aes(fill = Condition),
    color = "transparent",
    shape = 21,
    stroke = .4,
    size = 0.3,
    alpha = .1,
    position = position_jitter(seed = 1, height = 0.125)
  ) +
  # Add median as text
  stat_summary(
    geom = "text",
    fun = "median",
    aes(label = round(after_stat(x), 2),
        color = stage(Condition, after_scale = darken(color, .1, space = "HLS"))),
    family = "Roboto Mono",
    fontface = "bold",
    size = 4.5,
    vjust = -3.5
  ) +
  # Add sample size as text
  geom_text(
    data = sample_sizes,
    aes(x = 2010, y = Condition, label = paste("n =", n), color = Condition),
    inherit.aes = FALSE, # Prevent inheriting other aesthetics
    family = "Roboto Mono",
    size = 4,
    hjust = 0
  ) +
  # Add the labels of the y-axis
  scale_y_discrete(
    labels = c("WM Load 2", "WM Load 4", "WM Load 6")
  ) +
  # Set x-axis ticks
  scale_x_continuous(
    limits = c(200, 2250),
    breaks = seq(250, 2000, by = 250),
    expand = c(.001, .001)
  ) +
  # Disable legend
  scale_color_manual(values = pal, guide = "none") + 
  scale_fill_manual(values = pal, guide = "none") +
  # Set x- and y-axis labels and titles
  labs(
    x = "Reaction Time [ms]",
    y = NULL,
    title = "Reaction Time",
    subtitle = "Trial-by-Trial Reaction Time by Condition for the Sternberg Task",
  ) +
  # Set theme
  theme_minimal(base_family = "Zilla Slab", base_size = 15) +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    axis.ticks = element_blank(),
    axis.text.x = element_text(family = "Roboto Mono"),
    axis.text.y = element_text(
      color = darken(pal, .1, space = "HLS"), 
      size = 15
    ),
    axis.title.x = element_text(margin = margin(t = 10), size = 16),
    plot.subtitle = element_text(
      color = "grey40", hjust = 0,
      margin = margin(0, 0, 20, 0)
    ),
    plot.title.position = "plot",
    plot.margin = margin(15, 15, 10, 15)
  )

## ACCURACY across trials RAINPLOT  --------------------------------------------------------------------------------------------------------------
# Compute accuracy average
acc_avg <- dat %>%
  group_by(ID, Condition) %>%
  summarise(
    meanAcc = base::mean(Accuracy, na.rm = TRUE),
    .groups = "drop"
  )

# Transform accuracy to percentage
acc_avg$meanAcc <- acc_avg$meanAcc * 100

# Precompute sample sizes
 sample_sizes <- acc_avg |> 
   group_by(Condition) |> 
   summarise(n = n(), .groups = "drop")

# Rainplot
acc_avg |> 
  group_by(Condition) |> 
  # Define data to plot
  ggplot(aes(x = meanAcc, y = Condition)) + 
  ggdist::stat_halfeye(
    aes(color = Condition,
        fill = after_scale(lighten(color, .5))),
    adjust = .5,
    width = .5,
    height = .6,
    .width = 0, # Keep at 0 to remove middle line along data
    justification = -.4,
    point_color = NA
  ) +
  # Boxplot
  geom_boxplot(
    aes(color = stage(Condition, after_scale = darken(color, .1, space = "HLS")),
        fill = after_scale(desaturate(lighten(color, .8), .4))),
    width = .35, 
    outlier.shape = NA
  ) +
  # Display data points with jitter on y-axis
  geom_point(
    aes(color = stage(Condition, after_scale = darken(color, .1, space = "HLS"))),
    fill = "white",
    shape = 21,
    stroke = .4,
    size = 1.75,
    position = position_jitter(seed = 1, height = 0.125),
    alpha = .5
  ) +
  geom_point(
    aes(fill = Condition),
    color = "transparent",
    shape = 21,
    stroke = .4,
    size = 1.75,
    alpha = .3,
    position = position_jitter(seed = 1, height = 0.125)
  ) +
  # Add median as text
  stat_summary(
    geom = "text",
    fun = "median",
    aes(label = round(after_stat(x), 2),
        color = stage(Condition, after_scale = darken(color, .1, space = "HLS"))),
    family = "Roboto Mono",
    fontface = "bold",
    size = 4.5,
    vjust = -3.5
  ) +
  # Add sample size as text
  geom_text(
    data = sample_sizes,
    aes(x = 101, y = Condition, label = paste("n =", n), color = Condition),
    inherit.aes = FALSE, # Prevent inheriting other aesthetics
    family = "Roboto Mono",
    size = 4,
    hjust = 0
  ) +
  # Add the labels of the y-axis
  scale_y_discrete(
    labels = c("WM Load 2", "WM Load 4", "WM Load 6")
  ) +
  # Set x-axis ticks
  scale_x_continuous(
    limits = c(70, 107.5),
    breaks = seq(70, 100, by = 5),
    expand = c(.001, .001)
  ) +
  # Disable legend
  scale_color_manual(values = pal, guide = "none") + 
  scale_fill_manual(values = pal, guide = "none") +
  # Set x- and y-axis labels and titles
  labs(
    x = "Accuracy [%]",
    y = NULL,
    title = "Accuracy",
    subtitle = "Accuracy across Trials by Condition for the Sternberg Task",
  ) +
  # Set theme
  theme_minimal(base_family = "Zilla Slab", base_size = 15) +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    axis.ticks = element_blank(),
    axis.text.x = element_text(family = "Roboto Mono"),
    axis.text.y = element_text(
      color = darken(pal, .1, space = "HLS"), 
      size = 15
    ),
    axis.title.x = element_text(margin = margin(t = 10), size = 16),
    plot.subtitle = element_text(
      color = "grey40", hjust = 0,
      margin = margin(0, 0, 20, 0)
    ),
    plot.title.position = "plot",
    plot.margin = margin(15, 15, 10, 15)
  )
