# Written by: Cyril Versoza
# Date: December 2, 2022

# This script serves as the collection script for all the commands used in plotting the simulations graphs.

# Load library:
library(ggplot2)

# Load the data.
# chimp
chimp.western.dat <- read.table("mutation_matrix_chimp.pop0.tsv")
chimp.nigerian_cameroon.dat <- read.table("mutation_matrix_chimp.pop1.tsv")
chimp.central.dat <- read.table("mutation_matrix_chimp.pop2.tsv")
chimp.eastern.dat <- read.table("mutation_matrix_chimp.pop3.tsv")

# chimp singletons
chimp.western.singleton.dat <- read.table("mutation_matrix_chimp.singleton.pop0.tsv")
chimp.nigerian_cameroon.singleton.dat <- read.table("mutation_matrix_chimp.singleton.pop1.tsv")
chimp.central.singleton.dat <- read.table("mutation_matrix_chimp.singleton.pop2.tsv")
chimp.eastern.singleton.dat <- read.table("mutation_matrix_chimp.singleton.pop3.tsv")

# human
human.african.dat <- read.table("mutation_matrix_human.pop1.tsv")
human.european.dat <- read.table("mutation_matrix_human.pop2.tsv")
human.eastasian.dat <- read.table("mutation_matrix_human.pop3.tsv")

# human population-private
private.african.dat <- read.table("mutation_matrix_human.pop1.private.tsv")
private.european.dat <- read.table("mutation_matrix_human.pop2.private.tsv")
private.eastasian.dat <- read.table("mutation_matrix_human.pop3.private.tsv")

# simple
simple1.pop1.dat <- read.table("mutation_matrix_simple1.pop1.tsv")
simple2.pop1.dat <- read.table("mutation_matrix_simple2.pop1.tsv")
simple3.pop1.dat <- read.table("mutation_matrix_simple3.pop1.tsv")


# Rename columns.
colnames(chimp.western.dat) <- c("pop","sample_size","diff_percentage")
colnames(chimp.nigerian_cameroon.dat) <- c("pop","sample_size","diff_percentage")
colnames(chimp.central.dat) <- c("pop","sample_size","diff_percentage")
colnames(chimp.eastern.dat) <- c("pop","sample_size","diff_percentage")
colnames(chimp.western.singleton.dat) <- c("pop","sample_size","diff_percentage")
colnames(chimp.nigerian_cameroon.singleton.dat) <- c("pop","sample_size","diff_percentage")
colnames(chimp.central.singleton.dat) <- c("pop","sample_size","diff_percentage")
colnames(chimp.eastern.singleton.dat) <- c("pop","sample_size","diff_percentage")
colnames(human.african.dat) <- c("pop","sample_size","diff_percentage")
colnames(human.european.dat) <- c("pop","sample_size","diff_percentage")
colnames(human.eastasian.dat) <- c("pop","sample_size","diff_percentage")
colnames(simple1.pop1.dat) <- c("pop","sample_size","diff_percentage")
colnames(simple2.pop1.dat) <- c("pop","sample_size","diff_percentage")
colnames(simple3.pop1.dat) <- c("pop","sample_size","diff_percentage")
colnames(private.african.dat) <- c("sample_size","pop","ave_mutations")
colnames(private.european.dat) <- c("sample_size","pop","ave_mutations")
colnames(private.eastasian.dat) <- c("sample_size","pop","ave_mutations")

# Plot:
# chimp
ggplot() +
  geom_boxplot(chimp.western.dat, mapping = aes(x = as.factor(sample_size), y = diff_percentage, fill = "Western", color = "Western"), alpha = 0.35) +
  geom_boxplot(chimp.nigerian_cameroon.dat, mapping = aes(x = as.factor(sample_size), y = diff_percentage, fill = "Nigerian-Cameroon", color = "Nigerian-Cameroon"), alpha = 0.35) +
  geom_boxplot(chimp.central.dat, mapping = aes(x = as.factor(sample_size), y = diff_percentage, fill = "Central", color = "Central"), alpha = 0.35) +
  geom_boxplot(chimp.eastern.dat, mapping = aes(x = as.factor(sample_size), y = diff_percentage, fill = "Eastern", color = "Eastern"), alpha = 0.35) +
  ggtitle("CHIMP POPULATIONS") +
  xlab("sample size") + ylab("difference in percentage") +
  theme(
    plot.title = element_text(size=14, face="bold"),
    axis.title.x = element_text(size=14, face="bold"),
    axis.title.y = element_text(size=14, face="bold"),
    axis.text.x = element_text(size=14, angle = 90, vjust = 0.5, hjust=1),
    axis.text.y = element_text(size=14),
    panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
    panel.background = element_blank(), axis.line = element_line(colour = "black")
  ) +
  scale_fill_manual(values = c("Western" = "#961914", "Nigerian-Cameroon" = "#845c76", "Central" = "#beba64", "Eastern" = "#cc960e"), 
                    name = "POPULATION",
                    breaks = c("Western", "Nigerian-Cameroon", "Central", "Eastern")) +
  scale_color_manual(values = c("Western" = "#961914", "Nigerian-Cameroon" = "#845c76", "Central" = "#beba64", "Eastern" = "#cc960e"), 
                     name = "POPULATION",
                     breaks = c("Western", "Nigerian-Cameroon", "Central", "Eastern")) +
  ylim(0, 20)

# chimp singletons
ggplot() +
  geom_boxplot(chimp.western.singleton.dat, mapping = aes(x = as.factor(sample_size), y = diff_percentage, fill = "Western", color = "Western"), alpha = 0.35) +
  geom_boxplot(chimp.nigerian_cameroon.singleton.dat, mapping = aes(x = as.factor(sample_size), y = diff_percentage, fill = "Nigerian-Cameroon", color = "Nigerian-Cameroon"), alpha = 0.35) +
  geom_boxplot(chimp.central.singleton.dat, mapping = aes(x = as.factor(sample_size), y = diff_percentage, fill = "Central", color = "Central"), alpha = 0.35) +
  geom_boxplot(chimp.eastern.singleton.dat, mapping = aes(x = as.factor(sample_size), y = diff_percentage, fill = "Eastern", color = "Eastern"), alpha = 0.35) +
  ggtitle("CHIMP POPULATIONS (SINGLETONS)") +
  xlab("sample size") + ylab("difference in percentage") +
  theme(
    plot.title = element_text(size=14, face="bold"),
    axis.title.x = element_text(size=14, face="bold"),
    axis.title.y = element_text(size=14, face="bold"),
    axis.text.x = element_text(size=14, angle = 90, vjust = 0.5, hjust=1),
    axis.text.y = element_text(size=14),
    panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
    panel.background = element_blank(), axis.line = element_line(colour = "black")
  ) +
  scale_fill_manual(values = c("Western" = "#961914", "Nigerian-Cameroon" = "#845c76", "Central" = "#beba64", "Eastern" = "#cc960e"), 
                    name = "POPULATION",
                    breaks = c("Western", "Nigerian-Cameroon", "Central", "Eastern")) +
  scale_color_manual(values = c("Western" = "#961914", "Nigerian-Cameroon" = "#845c76", "Central" = "#beba64", "Eastern" = "#cc960e"), 
                     name = "POPULATION",
                     breaks = c("Western", "Nigerian-Cameroon", "Central", "Eastern")) +
  ylim(0, 20)

# human
ggplot() +
  geom_boxplot(human.african.dat, mapping = aes(x = as.factor(sample_size), y = diff_percentage, fill = "African", color = "African"), alpha = 0.35) +
  geom_boxplot(human.european.dat, mapping = aes(x = as.factor(sample_size), y = diff_percentage, fill = "European", color = "European"), alpha = 0.35) +
  geom_boxplot(human.eastasian.dat, mapping = aes(x = as.factor(sample_size), y = diff_percentage, fill = "East Asian", color = "East Asian"), alpha = 0.35) +
  ggtitle("HUMAN POPULATIONS") +
  xlab("sample size") + ylab("difference in percentage") +
  theme(
    plot.title = element_text(size=14, face="bold"),
    axis.title.x = element_text(size=14, face="bold"),
    axis.title.y = element_text(size=14, face="bold"),
    axis.text.x = element_text(size=14, angle = 90, vjust = 0.5, hjust=1),
    axis.text.y = element_text(size=14),
    panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
    panel.background = element_blank(), axis.line = element_line(colour = "black")
  ) +
  scale_fill_manual(values = c("African" = "#71a28f", "European" = "#375d8e", "East Asian" = "#bd7072"), 
                    name = "POPULATION",
                    breaks = c("African", "European", "East Asian")) +
  scale_color_manual(values = c("African" = "#71a28f", "European" = "#375d8e", "East Asian" = "#bd7072"), 
                    name = "POPULATION",
                    breaks = c("African", "European", "East Asian")) +
  ylim(0, 20)

# human population-private
ggplot() +
  geom_line(private.african.dat, mapping = aes(x = as.factor(sample_size), y = ave_mutations, color = "African", color = "African", group = 1), alpha = 0.35) +
  geom_line(private.european.dat, mapping = aes(x = as.factor(sample_size), y = ave_mutations, color = "European", color = "European", group = 1), alpha = 0.35) +
  geom_line(private.eastasian.dat, mapping = aes(x = as.factor(sample_size), y = ave_mutations, color = "East Asian", color = "East Asian", group = 1), alpha = 0.35) +
  ggtitle("HUMAN POPULATIONS (POPULATION-PRIVATE MUTATIONS)") +
  xlab("sample size") + ylab("average total mutations") +
  theme(
    plot.title = element_text(size=14, face="bold"),
    axis.title.x = element_text(size=14, face="bold"),
    axis.title.y = element_text(size=14, face="bold"),
    axis.text.x = element_text(size=14, angle = 90, vjust = 0.5, hjust=1),
    axis.text.y = element_text(size=14),
    panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
    panel.background = element_blank(), axis.line = element_line(colour = "black")
  ) +
  scale_color_manual(values = c("African" = "#71a28f", "European" = "#375d8e", "East Asian" = "#bd7072"), 
                    name = "POPULATION",
                    breaks = c("African", "European", "East Asian")) +
  scale_color_manual(values = c("African" = "#71a28f", "European" = "#375d8e", "East Asian" = "#bd7072"), 
                     name = "POPULATION",
                     breaks = c("African", "European", "East Asian"))

# simple
ggplot() +
  geom_boxplot(simple1.pop1.dat, mapping = aes(x = as.factor(sample_size), y = diff_percentage, fill = "Bottleneck", color = "Bottleneck"), alpha = 0.35) +
  geom_boxplot(simple2.pop1.dat, mapping = aes(x = as.factor(sample_size), y = diff_percentage, fill = "Growth", color = "Growth"), alpha = 0.35) +
  geom_boxplot(simple3.pop1.dat, mapping = aes(x = as.factor(sample_size), y = diff_percentage, fill = "Constant", color = "Constant"), alpha = 0.35) +
  ggtitle("SIMPLE MODEL POPULATIONS") +
  xlab("sample size") + ylab("difference in percentage") +
  theme(
    plot.title = element_text(size=14, face="bold"),
    axis.title.x = element_text(size=14, face="bold"),
    axis.title.y = element_text(size=14, face="bold"),
    axis.text.x = element_text(size=14, angle = 90, vjust = 0.5, hjust=1),
    axis.text.y = element_text(size=14),
    panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
    panel.background = element_blank(), axis.line = element_line(colour = "black")
  ) +
  scale_fill_manual(values = c("Constant" = "#868686", "Bottleneck" = "#CB5B3E", "Growth" = "#1F8856"), 
                    name = "DEMOGRAPHIC HISTORY",
                    breaks = c("Constant", "Bottleneck", "Growth")) +
  scale_color_manual(values = c("Constant" = "#868686", "Bottleneck" = "#CB5B3E", "Growth" = "#1F8856"), 
                     name = "DEMOGRAPHIC HISTORY",
                     breaks = c("Constant", "Bottleneck", "Growth")) +
  ylim(0, 30)

