library(tidyverse)
library(httr)
library(lubridate)

#API slóðir fyrir Grensásveg (Mælistöð 02)
param_url_NO2  <- "http://loftapi.reykjavik.is/api/v1/stations/data/02/12/08-01-2016/0/0/11-06-2016/23/30"
param_url_SO2  <- "http://loftapi.reykjavik.is/api/v1/stations/data/02/41/08-01-2016/0/0/11-06-2016/23/30"
param_url_H2S  <- "http://loftapi.reykjavik.is/api/v1/stations/data/02/42/08-01-2016/0/0/11-06-2016/23/30"
param_url_PM10 <- "http://loftapi.reykjavik.is/api/v1/stations/data/02/91/08-01-2016/0/0/11-06-2016/23/30"

#Búum til lista sem inniheldur allar slóðirnar sem við viljum nálgast
param_url <- list(param_url_NO2, param_url_SO2, param_url_H2S, param_url_PM10)
lengd <- length(param_url)

#Notum GET() til að tengjast API og sækja gögnin. Notum lapply() til að gera þetta fyrir allar slóðirnar
#í param_url listanum
allt <- lapply(X = param_url, GET)

#Lúppum okkur í gegn til að smíða kassalaga gagnasett, ramma (sem er listaveisla enn sem komið er)
allt_content_radad <- vector("list", length = lengd)
for (i in 1:lengd) {
  allt_content <- content(allt[[i]])
  allt_content_radad[[i]] <- do.call(rbind, allt_content) 
}

#Breytum gögnunum úr listum í gagnaramma
rammi <- do.call(rbind, allt_content_radad)
gagnarammi <- as_data_frame(matrix(nrow = nrow(rammi), ncol = ncol(rammi)))
breidd <- ncol(rammi)
for (j in 1:breidd) {
  gagnarammi[, j] <- unlist(rammi[, j])
}

#Gefum dálkum rétt nöfn með lágstöfum
names(gagnarammi) <- rammi[1,] %>%
  names() %>%
  str_to_lower()

#Gerum dálkinn 'time' að POSIXct (date-time) object
gagnarammi <- gagnarammi %>% 
  mutate(time = ymd_hms(time))
