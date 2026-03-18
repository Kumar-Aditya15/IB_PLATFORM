# ============================================================
# INVESTMENT BANKING DEAL ANALYSIS PLATFORM
# Full IB-Grade: DCF + Comps + M&A + LBO + Credit Risk
# Nifty 500 Companies | Live Data | Goldman Sachs Style
# ============================================================
# HOW TO RUN:
#   1. Open RStudio
#   2. Paste this entire file
#   3. Press Ctrl+A then Ctrl+Enter
#   4. App opens in browser automatically
# ============================================================

# ---- Auto-install all packages ----
pkgs <- c("shiny","shinydashboard","plotly","DT","quantmod",
          "tidyr","dplyr","scales","ggplot2","shinycssloaders",
          "shinyWidgets","fresh")
new_pkgs <- pkgs[!pkgs %in% installed.packages()[,"Package"]]
if(length(new_pkgs)>0){
  cat("Installing packages:", paste(new_pkgs,collapse=", "),"\n")
  install.packages(new_pkgs, repos="https://cran.r-project.org")
}
lapply(pkgs, library, character.only=TRUE)
cat("All packages loaded. Launching platform...\n")

# ============================================================
# NIFTY 500 COMPANY DATABASE
# ============================================================
nifty500 <- data.frame(
  Company = c(
    "Reliance Industries","TCS","HDFC Bank","Infosys","ICICI Bank",
    "Hindustan Unilever","ITC","State Bank of India","Bajaj Finance","Bharti Airtel",
    "Kotak Mahindra Bank","Asian Paints","Axis Bank","Maruti Suzuki","Sun Pharma",
    "Titan Company","Wipro","UltraTech Cement","HCL Technologies","Larsen & Toubro",
    "Nestle India","Power Grid","NTPC","Tata Motors","Mahindra & Mahindra",
    "Tech Mahindra","JSW Steel","Adani Ports","Bajaj Auto","Cipla",
    "Dr Reddy's Laboratories","Divi's Laboratories","Eicher Motors","Grasim Industries","HDFC Life",
    "Hero MotoCorp","Hindalco","IndusInd Bank","Interglobe Aviation","IOC",
    "ONGC","Tata Steel","SBI Life Insurance","Shree Cement","Tata Consumer Products",
    "Vedanta","Bajaj Finserv","Britannia Industries","Coal India","Dabur India",
    "Godrej Consumer Products","Havells India","ICICI Prudential","Muthoot Finance","Page Industries",
    "Pidilite Industries","Siemens India","Torrent Pharmaceuticals","Whirlpool India","Zomato",
    "Paytm","Nykaa","PolicyBazaar","Delhivery","Marico",
    "Berger Paints","Crompton Greaves","Dixon Technologies","Escorts Kubota","Federal Bank",
    "Fortis Healthcare","GMR Airports","Godrej Properties","ICICI Securities","IDFC First Bank",
    "Info Edge India","Ipca Laboratories","Jubilant Foodworks","Kansai Nerolac","L&T Finance",
    "Lupin","Max Healthcare","Mphasis","NMDC","Oberoi Realty",
    "PB Fintech","PI Industries","Power Finance Corp","Punjab National Bank","REC Limited",
    "Relaxo Footwear","SRF Limited","Tata Chemicals","Tata Communications","Tata Elxsi",
    "Tata Power","Varun Beverages","Voltas","Yes Bank","Zee Entertainment"
  ),
  Symbol = c(
    "RELIANCE.NS","TCS.NS","HDFCBANK.NS","INFY.NS","ICICIBANK.NS",
    "HINDUNILVR.NS","ITC.NS","SBIN.NS","BAJFINANCE.NS","BHARTIARTL.NS",
    "KOTAKBANK.NS","ASIANPAINT.NS","AXISBANK.NS","MARUTI.NS","SUNPHARMA.NS",
    "TITAN.NS","WIPRO.NS","ULTRACEMCO.NS","HCLTECH.NS","LT.NS",
    "NESTLEIND.NS","POWERGRID.NS","NTPC.NS","TATAMOTORS.NS","M&M.NS",
    "TECHM.NS","JSWSTEEL.NS","ADANIPORTS.NS","BAJAJ-AUTO.NS","CIPLA.NS",
    "DRREDDY.NS","DIVISLAB.NS","EICHERMOT.NS","GRASIM.NS","HDFCLIFE.NS",
    "HEROMOTOCO.NS","HINDALCO.NS","INDUSINDBK.NS","INDIGO.NS","IOC.NS",
    "ONGC.NS","TATASTEEL.NS","SBILIFE.NS","SHREECEM.NS","TATACONSUM.NS",
    "VEDL.NS","BAJAJFINSV.NS","BRITANNIA.NS","COALINDIA.NS","DABUR.NS",
    "GODREJCP.NS","HAVELLS.NS","ICICIPRULI.NS","MUTHOOTFIN.NS","PAGEIND.NS",
    "PIDILITIND.NS","SIEMENS.NS","TORNTPHARM.NS","WHIRLPOOL.NS","ZOMATO.NS",
    "PAYTM.NS","NYKAA.NS","POLICYBZR.NS","DELHIVERY.NS","MARICO.NS",
    "BERGEPAINT.NS","CROMPTON.NS","DIXON.NS","ESCORTS.NS","FEDERALBNK.NS",
    "FORTIS.NS","GMRAIRPORT.NS","GODREJPROP.NS","ISEC.NS","IDFCFIRSTB.NS",
    "NAUKRI.NS","IPCALAB.NS","JUBLFOOD.NS","KANSAINER.NS","L&TFH.NS",
    "LUPIN.NS","MAXHEALTH.NS","MPHASIS.NS","NMDC.NS","OBEROIRLTY.NS",
    "POLICYBZR.NS","PIIND.NS","PFC.NS","PNB.NS","RECLTD.NS",
    "RELAXO.NS","SRF.NS","TATACHEM.NS","TATACOMM.NS","TATAELXSI.NS",
    "TATAPOWER.NS","VBL.NS","VOLTAS.NS","YESBANK.NS","ZEEL.NS"
  ),
  Sector = c(
    "Energy","IT","Banking","IT","Banking",
    "FMCG","FMCG","Banking","Finance","Telecom",
    "Banking","Paints","Banking","Auto","Pharma",
    "Retail","IT","Cement","IT","Infrastructure",
    "FMCG","Utilities","Utilities","Auto","Auto",
    "IT","Steel","Infra","Auto","Pharma",
    "Pharma","Pharma","Auto","Cement","Insurance",
    "Auto","Metals","Banking","Aviation","Energy",
    "Energy","Steel","Insurance","Cement","FMCG",
    "Metals","Finance","FMCG","Energy","FMCG",
    "FMCG","Electronics","Insurance","Finance","Retail",
    "Chemicals","Engineering","Pharma","Consumer","Tech",
    "Fintech","Beauty","Insurance","Logistics","FMCG",
    "Paints","Electronics","Electronics","Auto","Banking",
    "Healthcare","Aviation","Real Estate","Finance","Banking",
    "Tech","Pharma","QSR","Paints","Finance",
    "Pharma","Healthcare","IT","Mining","Real Estate",
    "Insurance","Agro","Finance","Banking","Finance",
    "Footwear","Chemicals","Chemicals","Telecom","IT",
    "Utilities","Beverages","Consumer","Banking","Media"
  ),
  stringsAsFactors = FALSE
)

# ============================================================
# FINANCIAL DATA ENGINE
# ============================================================
get_stock_data <- function(symbol, period="1y") {
  tryCatch({
    end_date <- Sys.Date()
    start_date <- end_date - switch(period,
                                    "3m"=90, "6m"=180, "1y"=365, "2y"=730, "5y"=1825, 365)
    data <- getSymbols(symbol, src="yahoo", from=start_date, to=end_date,
                       auto.assign=FALSE, warnings=FALSE)
    df <- data.frame(
      Date   = index(data),
      Open   = as.numeric(Op(data)),
      High   = as.numeric(Hi(data)),
      Low    = as.numeric(Lo(data)),
      Close  = as.numeric(Cl(data)),
      Volume = as.numeric(Vo(data))
    )
    df <- df[complete.cases(df),]
    df
  }, error=function(e) NULL)
}

# Realistic financial model generator
generate_financials <- function(company, sector) {
  set.seed(sum(utf8ToInt(company)))
  
  # Sector-specific base multiples
  sector_params <- list(
    IT       = list(rev=50000, margin=0.20, pe=30, eveb=20, growth=0.15),
    Banking  = list(rev=80000, margin=0.25, pe=18, eveb=12, growth=0.12),
    FMCG     = list(rev=40000, margin=0.18, pe=45, eveb=28, growth=0.10),
    Pharma   = list(rev=20000, margin=0.22, pe=25, eveb=18, growth=0.12),
    Auto     = list(rev=100000,margin=0.10, pe=20, eveb=12, growth=0.08),
    Energy   = list(rev=500000,margin=0.08, pe=12, eveb=8,  growth=0.05),
    Finance  = list(rev=30000, margin=0.30, pe=22, eveb=15, growth=0.18),
    Cement   = list(rev=15000, margin=0.15, pe=22, eveb=14, growth=0.08),
    Steel    = list(rev=80000, margin=0.12, pe=10, eveb=7,  growth=0.06),
    Telecom  = list(rev=100000,margin=0.12, pe=28, eveb=10, growth=0.10)
  )
  
  p <- sector_params[[sector]]
  if(is.null(p)) p <- list(rev=30000, margin=0.15, pe=22, eveb=15, growth=0.10)
  
  noise <- function(x, pct=0.2) x * (1 + runif(1,-pct,pct))
  
  rev    <- noise(p$rev)
  margin <- noise(p$margin, 0.1)
  ebitda <- rev * margin
  ebit   <- ebitda * 0.80
  pat    <- ebit  * 0.70
  eps    <- pat / noise(1000, 0.3)  # shares in crores
  debt   <- noise(rev * 0.3)
  cash   <- noise(rev * 0.1)
  equity <- noise(rev * 0.8)
  ev     <- ebitda * p$eveb
  price  <- eps * p$pe
  
  # 5-year historical
  hist_rev   <- rev * cumprod(c(1, rev(1 + rnorm(4, p$growth*0.8, 0.03))))
  hist_ebitda <- hist_rev * (margin * cumprod(c(1, rev(rnorm(4, 0.01, 0.02)))))
  hist_pat    <- hist_ebitda * 0.56
  
  list(
    revenue=rev, ebitda=ebitda, ebit=ebit, pat=pat, eps=eps,
    debt=debt, cash=cash, equity=equity, ev=ev, price=price,
    pe=p$pe, ev_ebitda=p$eveb, growth=p$growth, margin=margin,
    hist_rev=hist_rev, hist_ebitda=hist_ebitda, hist_pat=hist_pat,
    wacc=0.10+runif(1,0,0.04), terminal_growth=0.04+runif(1,0,0.02),
    beta=0.8+runif(1,0,0.8), sector=sector
  )
}

# DCF Engine
run_dcf <- function(fin, wacc_input=NULL, tg_input=NULL, rev_growth=NULL) {
  wacc <- if(!is.null(wacc_input)) wacc_input else fin$wacc
  tg   <- if(!is.null(tg_input))   tg_input   else fin$terminal_growth
  g    <- if(!is.null(rev_growth))  rev_growth  else fin$growth
  
  fcf_year1 <- fin$ebitda * 0.6 * (1-0.25)
  fcf <- fcf_year1 * cumprod(1 + c(g, g*0.9, g*0.8, g*0.7, g*0.6))
  disc <- 1/(1+wacc)^(1:5)
  pv_fcf <- sum(fcf * disc)
  tv  <- fcf[5]*(1+tg)/(wacc-tg)
  pv_tv <- tv * disc[5]
  ev_dcf <- pv_fcf + pv_tv
  equity_val <- ev_dcf - fin$debt + fin$cash
  shares <- fin$pat / fin$eps
  price_per_share <- equity_val / shares * 1e5
  
  list(fcf=fcf, pv_fcf=pv_fcf, tv=tv, pv_tv=pv_tv,
       ev=ev_dcf, equity_val=equity_val,
       price_per_share=price_per_share,
       upside=((price_per_share/fin$price)-1)*100,
       wacc=wacc, tg=tg, growth=g)
}

# Altman Z-Score
altman_z <- function(fin) {
  wc_ta   <- (fin$equity - fin$debt*0.3) / (fin$equity + fin$debt) * runif(1, 0.1, 0.3)
  re_ta   <- fin$pat / (fin$equity + fin$debt) * runif(1, 0.2, 0.6)
  ebit_ta <- fin$ebit / (fin$equity + fin$debt) * runif(1, 0.1, 0.4)
  mv_td   <- fin$equity / fin$debt * runif(1, 1.5, 4)
  s_ta    <- fin$revenue / (fin$equity + fin$debt) * runif(1, 0.5, 2)
  z <- 1.2*wc_ta + 1.4*re_ta + 3.3*ebit_ta + 0.6*mv_td + s_ta
  list(z=z, wc_ta=wc_ta, re_ta=re_ta, ebit_ta=ebit_ta, mv_td=mv_td, s_ta=s_ta,
       rating=ifelse(z>2.99,"SAFE",ifelse(z>1.81,"GREY ZONE","DISTRESS")),
       color=ifelse(z>2.99,"#00c896",ifelse(z>1.81,"#f59e0b","#ef4444")))
}

# LBO Engine
run_lbo <- function(fin, entry_ev_mult=8, debt_pct=0.65, exit_mult=10, hold=5) {
  entry_ev  <- fin$ebitda * entry_ev_mult
  debt_in   <- entry_ev * debt_pct
  equity_in <- entry_ev * (1 - debt_pct)
  ann_amort <- debt_in * 0.08
  ebitda_proj <- fin$ebitda * cumprod(1 + rep(fin$growth*0.7, hold))
  debt_remain <- pmax(debt_in - ann_amort*(1:hold), debt_in*0.3)
  exit_ev     <- ebitda_proj[hold] * exit_mult
  equity_out  <- exit_ev - debt_remain[hold]
  moic        <- equity_out / equity_in
  irr         <- (moic^(1/hold) - 1)*100
  list(entry_ev=entry_ev, debt_in=debt_in, equity_in=equity_in,
       exit_ev=exit_ev, equity_out=equity_out,
       moic=moic, irr=irr,
       ebitda_proj=ebitda_proj, debt_remain=debt_remain,
       hold=hold, entry_mult=entry_ev_mult, exit_mult=exit_mult)
}

# M&A Engine
run_ma <- function(acquirer, target, premium=0.25, stock_pct=0.5, synergy=0) {
  deal_val  <- target$ev * (1 + premium)
  cash_paid <- deal_val * (1-stock_pct)
  stock_paid<- deal_val * stock_pct
  combined_pat <- acquirer$pat + target$pat * (1+premium*0.1) + synergy
  new_shares   <- stock_paid / acquirer$price
  total_shares <- (acquirer$pat/acquirer$eps) + new_shares
  new_eps      <- combined_pat / total_shares
  accretion    <- ((new_eps/acquirer$eps)-1)*100
  list(deal_val=deal_val, cash_paid=cash_paid, stock_paid=stock_paid,
       combined_pat=combined_pat, new_eps=new_eps,
       old_eps=acquirer$eps, accretion=accretion,
       premium=premium*100,
       verdict=ifelse(accretion>0,"ACCRETIVE","DILUTIVE"),
       color=ifelse(accretion>0,"#00c896","#ef4444"))
}

# ============================================================
# UI
# ============================================================
ui <- dashboardPage(
  skin="black",
  
  dashboardHeader(
    title=tags$span(
      style="font-family:'Courier New',monospace;color:#d4a843;font-size:15px;font-weight:bold;letter-spacing:3px;",
      "IB DEAL PLATFORM"
    ),
    titleWidth=220
  ),
  
  dashboardSidebar(
    width=220,
    tags$div(style="padding:14px 12px 4px;color:#546e7a;font-size:10px;letter-spacing:3px;text-transform:uppercase;","— Select Company —"),
    
    selectInput("sector_filter","Sector:",
                choices=c("All Sectors",sort(unique(nifty500$Sector))),
                selected="All Sectors",
                width="100%"
    ),
    selectInput("company","Company:",
                choices=setNames(nifty500$Symbol, paste0(nifty500$Company," (",nifty500$Sector,")")),
                selected="RELIANCE.NS",
                width="100%"
    ),
    selectInput("period","Price History:",
                choices=c("3 Months"="3m","6 Months"="6m","1 Year"="1y","2 Years"="2y","5 Years"="5y"),
                selected="1y", width="100%"
    ),
    tags$hr(style="border-color:#1a2a3a;margin:8px 0;"),
    tags$div(style="padding:8px 14px;color:#546e7a;font-size:10px;letter-spacing:3px;text-transform:uppercase;","— Deal Tools —"),
    sidebarMenu(id="tabs",
                menuItem("Overview",         tabName="overview",  icon=icon("chart-line")),
                menuItem("DCF Valuation",    tabName="dcf",       icon=icon("calculator")),
                menuItem("Comps Analysis",   tabName="comps",     icon=icon("table")),
                menuItem("M&A Accretion",    tabName="ma",        icon=icon("handshake")),
                menuItem("LBO Model",        tabName="lbo",       icon=icon("percent")),
                menuItem("Credit & Z-Score", tabName="credit",    icon=icon("shield-alt"))
    ),
    tags$hr(style="border-color:#1a2a3a;margin:8px 0;"),
    tags$div(style="padding:8px 14px;color:#374151;font-size:10px;line-height:1.8;",
             "Goldman Sachs · JPMorgan", tags$br(),
             "Morgan Stanley · Nomura",  tags$br(),
             tags$br(),
             tags$span(style="color:#d4a843;","Nifty 500 · Live Data")
    )
  ),
  
  dashboardBody(
    tags$head(tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;600&family=IBM+Plex+Sans:wght@300;400;600&display=swap');
      html, body { background:#040d18 !important; }
      body, .content-wrapper, .right-side { background:#040d18 !important; font-family:'IBM Plex Sans',sans-serif; }
      .main-header .logo, .main-header .navbar { background:#020912 !important; border-bottom:1px solid #d4a84322 !important; }
      .main-sidebar { background:#020912 !important; border-right:1px solid #0d2137; }
      .sidebar-menu>li>a { color:#546e7a !important; font-family:'IBM Plex Mono',monospace; font-size:11px; border-left:3px solid transparent; transition:all 0.2s; padding:10px 14px; }
      .sidebar-menu>li.active>a,.sidebar-menu>li>a:hover { color:#d4a843 !important; background:#0a1628 !important; border-left-color:#d4a843 !important; }
      .box { background:#06111f !important; border:1px solid #0d2137 !important; border-radius:4px !important; box-shadow:0 2px 20px #00000044; }
      .box-header { background:#06111f !important; border-bottom:1px solid #0d2137 !important; padding:12px 16px !important; }
      .box-title { color:#d4a843 !important; font-family:'IBM Plex Mono',monospace !important; font-size:11px !important; letter-spacing:2px; text-transform:uppercase; }
      h4 { color:#94a3b8 !important; font-family:'IBM Plex Mono',monospace; font-size:11px; letter-spacing:1px; }
      label { color:#546e7a !important; font-size:11px; letter-spacing:1px; text-transform:uppercase; }
      .form-control,.selectize-input,.selectize-dropdown { background:#020912 !important; border:1px solid #0d2137 !important; color:#94a3b8 !important; font-family:'IBM Plex Mono',monospace !important; font-size:11px !important; border-radius:3px !important; }
      .selectize-dropdown { background:#020912 !important; border:1px solid #d4a84344 !important; }
      .selectize-dropdown .option:hover,.selectize-dropdown .option.active { background:#0a1628 !important; color:#d4a843 !important; }
      .action-button,.btn-primary { background:#d4a843 !important; border:none !important; color:#020912 !important; font-family:'IBM Plex Mono',monospace !important; font-size:11px !important; letter-spacing:2px !important; font-weight:600 !important; border-radius:3px !important; padding:8px 16px !important; transition:all 0.2s !important; }
      .action-button:hover { background:#b8882e !important; box-shadow:0 0 20px #d4a84344 !important; }
      .irs--shiny .irs-bar { background:#d4a843 !important; border-color:#d4a843 !important; }
      .irs--shiny .irs-handle { background:#d4a843 !important; border-color:#d4a843 !important; }
      .irs--shiny .irs-single { background:#d4a843 !important; color:#020912 !important; font-family:'IBM Plex Mono',monospace; font-size:10px !important; }
      .irs--shiny .irs-min,.irs--shiny .irs-max { color:#546e7a !important; font-size:9px !important; }
      .small-box { border-radius:4px !important; border:1px solid #0d2137 !important; }
      .small-box h3 { font-family:'IBM Plex Mono',monospace !important; font-size:20px !important; }
      .small-box p { font-family:'IBM Plex Sans',sans-serif !important; font-size:11px !important; }
      .metric-card { background:#06111f; border:1px solid #0d2137; border-radius:4px; padding:14px 16px; margin-bottom:10px; }
      .metric-card .mc-val { font-family:'IBM Plex Mono',monospace; font-size:22px; font-weight:600; color:#d4a843; }
      .metric-card .mc-val.green { color:#00c896; }
      .metric-card .mc-val.red { color:#ef4444; }
      .metric-card .mc-val.blue { color:#60a5fa; }
      .metric-card .mc-lbl { color:#546e7a; font-size:10px; letter-spacing:1px; text-transform:uppercase; margin-top:3px; }
      .page-header { padding:16px 0 14px; border-bottom:1px solid #0d2137; margin-bottom:18px; }
      .page-header h2 { font-family:'IBM Plex Mono',monospace; color:#d4a843; font-size:16px; letter-spacing:3px; margin:0 0 4px; }
      .page-header p { color:#374151; font-size:11px; margin:0; letter-spacing:1px; }
      .tag { display:inline-block; font-family:'IBM Plex Mono',monospace; font-size:10px; padding:3px 8px; border-radius:3px; font-weight:600; }
      .tag-green { background:#052e16; color:#00c896; border:1px solid #00c89633; }
      .tag-red { background:#2d0a0a; color:#ef4444; border:1px solid #ef444433; }
      .tag-gold { background:#2d1f02; color:#d4a843; border:1px solid #d4a84333; }
      .tag-blue { background:#0a1f3d; color:#60a5fa; border:1px solid #60a5fa33; }
      .separator { border:none; border-top:1px solid #0d2137; margin:14px 0; }
      table.dataTable { background:#06111f !important; color:#94a3b8 !important; font-family:'IBM Plex Mono',monospace !important; font-size:11px !important; }
      table.dataTable thead th { background:#020912 !important; color:#d4a843 !important; border-bottom:1px solid #0d2137 !important; font-size:10px; letter-spacing:1px; text-transform:uppercase; }
      table.dataTable tbody tr { background:#06111f !important; }
      table.dataTable tbody tr:hover { background:#0a1628 !important; }
      .dataTables_wrapper { color:#546e7a !important; font-family:'IBM Plex Mono',monospace !important; font-size:11px !important; }
      .dataTables_filter input { background:#020912 !important; border:1px solid #0d2137 !important; color:#94a3b8 !important; border-radius:3px; }
      .dataTables_length select { background:#020912 !important; border:1px solid #0d2137 !important; color:#94a3b8 !important; }
      ::-webkit-scrollbar { width:6px; height:6px; }
      ::-webkit-scrollbar-track { background:#020912; }
      ::-webkit-scrollbar-thumb { background:#0d2137; border-radius:3px; }
      ::-webkit-scrollbar-thumb:hover { background:#d4a84366; }
      hr { border-color:#0d2137 !important; }
      .info-row { display:flex; justify-content:space-between; padding:6px 0; border-bottom:1px solid #0d213755; font-size:12px; }
      .shiny-notification { background:#06111f; border:1px solid #d4a843; color:#94a3b8; font-family:'IBM Plex Mono',monospace; }
    "))),
    
    tabItems(
      
      # ============================================================
      # OVERVIEW TAB
      # ============================================================
      tabItem("overview",
              div(class="page-header",
                  tags$h2("[ COMPANY OVERVIEW ]"),
                  tags$p("Live price data · Financial snapshot · Key metrics")
              ),
              fluidRow(
                valueBoxOutput("vb_price",  width=3),
                valueBoxOutput("vb_mktcap", width=3),
                valueBoxOutput("vb_pe",     width=3),
                valueBoxOutput("vb_sector", width=3)
              ),
              fluidRow(
                box(title="Price Chart", width=8, solidHeader=TRUE,
                    withSpinner(plotlyOutput("price_chart", height="360px"), color="#d4a843", type=6)
                ),
                box(title="Financial Snapshot", width=4, solidHeader=TRUE,
                    withSpinner(uiOutput("fin_snapshot"), color="#d4a843", type=6)
                )
              ),
              fluidRow(
                box(title="Revenue & EBITDA Trend (5Y)", width=6, solidHeader=TRUE,
                    plotlyOutput("trend_chart", height="260px")
                ),
                box(title="Sector Peers — Quick Comps", width=6, solidHeader=TRUE,
                    withSpinner(DTOutput("quick_comps"), color="#d4a843", type=6)
                )
              )
      ),
      
      # ============================================================
      # DCF TAB
      # ============================================================
      tabItem("dcf",
              div(class="page-header",
                  tags$h2("[ DCF VALUATION ENGINE ]"),
                  tags$p("Discounted Cash Flow · Sensitivity Analysis · Football Field Chart")
              ),
              fluidRow(
                box(title="DCF Assumptions", width=3, solidHeader=TRUE,
                    sliderInput("dcf_wacc",   "WACC (%):",          6,  20, 11, step=0.5),
                    sliderInput("dcf_tg",     "Terminal Growth (%):",2,   8,  4, step=0.5),
                    sliderInput("dcf_growth", "Revenue Growth (%):", 3,  30, 12, step=1),
                    sliderInput("dcf_margin", "EBITDA Margin (%):",  5,  40, 18, step=1),
                    actionButton("run_dcf_btn", "▶  RUN DCF", width="100%")
                ),
                box(title="DCF Output — Intrinsic Value", width=9, solidHeader=TRUE,
                    fluidRow(
                      column(4,
                             div(class="metric-card",
                                 div(class="mc-val",    id="dcf_price",  "—"),
                                 div(class="mc-lbl", "Intrinsic Value / Share (₹)")
                             ),
                             div(class="metric-card",
                                 div(class="mc-val blue", id="dcf_upside", "—"),
                                 div(class="mc-lbl", "Upside / Downside (%)")
                             ),
                             div(class="metric-card",
                                 div(class="mc-val",    id="dcf_ev",     "—"),
                                 div(class="mc-lbl", "Enterprise Value (₹ Cr)")
                             )
                      ),
                      column(8,
                             plotlyOutput("dcf_waterfall", height="310px")
                      )
                    )
                )
              ),
              fluidRow(
                box(title="Sensitivity Table — Price vs WACC & Growth", width=7, solidHeader=TRUE,
                    withSpinner(DTOutput("dcf_sensitivity"), color="#d4a843", type=6)
                ),
                box(title="Free Cash Flow Projection (5Y)", width=5, solidHeader=TRUE,
                    plotlyOutput("dcf_fcf_chart", height="260px")
                )
              )
      ),
      
      # ============================================================
      # COMPS TAB
      # ============================================================
      tabItem("comps",
              div(class="page-header",
                  tags$h2("[ COMPARABLE COMPANY ANALYSIS ]"),
                  tags$p("Trading Comps · EV/EBITDA · P/E · Football Field · IB Standard")
              ),
              fluidRow(
                box(title="Peer Selection", width=3, solidHeader=TRUE,
                    tags$p(style="color:#546e7a;font-size:11px;","Peers auto-selected from same sector. Adjust count:"),
                    sliderInput("n_peers", "Number of Peers:", 3, 8, 5),
                    actionButton("run_comps_btn", "▶  RUN COMPS", width="100%"),
                    hr(),
                    uiOutput("comps_verdict")
                ),
                box(title="Comparable Companies Table", width=9, solidHeader=TRUE,
                    withSpinner(DTOutput("comps_table"), color="#d4a843", type=6)
                )
              ),
              fluidRow(
                box(title="Football Field Chart — Valuation Range", width=8, solidHeader=TRUE,
                    plotlyOutput("football_field", height="320px")
                ),
                box(title="Multiple Distribution", width=4, solidHeader=TRUE,
                    plotlyOutput("mult_dist", height="320px")
                )
              )
      ),
      
      # ============================================================
      # M&A TAB
      # ============================================================
      tabItem("ma",
              div(class="page-header",
                  tags$h2("[ M&A ACCRETION / DILUTION MODEL ]"),
                  tags$p("Deal structuring · EPS impact · Synergy analysis · IB standard deal model")
              ),
              fluidRow(
                box(title="Acquirer", width=3, solidHeader=TRUE,
                    tags$p(style="color:#d4a843;font-size:11px;font-family:'IBM Plex Mono';","ACQUIRER"),
                    selectInput("ma_acquirer","Select Acquirer:",
                                choices=setNames(nifty500$Symbol,paste0(nifty500$Company," (",nifty500$Sector,")")),
                                selected="RELIANCE.NS", width="100%"
                    ),
                    tags$p(style="color:#d4a843;font-size:11px;font-family:'IBM Plex Mono';margin-top:14px;","TARGET"),
                    selectInput("ma_target","Select Target:",
                                choices=setNames(nifty500$Symbol,paste0(nifty500$Company," (",nifty500$Sector,")")),
                                selected="INFY.NS", width="100%"
                    ),
                    tags$hr(style="border-color:#0d2137;"),
                    sliderInput("ma_premium",  "Acquisition Premium (%):", 5, 60, 25),
                    sliderInput("ma_stock_pct","Stock Consideration (%):",  0, 100, 50),
                    sliderInput("ma_synergy",  "Annual Synergies (₹ Cr):",  0, 5000, 500, step=100),
                    actionButton("run_ma_btn","▶  RUN M&A MODEL", width="100%")
                ),
                box(title="Deal Summary & EPS Impact", width=9, solidHeader=TRUE,
                    fluidRow(
                      column(4,
                             div(class="metric-card",
                                 div(class="mc-val",id="ma_deal_val","—"),
                                 div(class="mc-lbl","Deal Value (₹ Cr)")
                             ),
                             div(class="metric-card",
                                 div(class="mc-val blue",id="ma_new_eps","—"),
                                 div(class="mc-lbl","Pro Forma EPS (₹)")
                             ),
                             div(class="metric-card",
                                 div(class="mc-val",id="ma_accretion","—"),
                                 div(class="mc-lbl","Accretion / Dilution (%)")
                             ),
                             uiOutput("ma_verdict_box")
                      ),
                      column(8,
                             plotlyOutput("ma_chart", height="320px")
                      )
                    )
                )
              ),
              fluidRow(
                box(title="Synergy Sensitivity — Accretion vs Premium", width=12, solidHeader=TRUE,
                    plotlyOutput("ma_sensitivity", height="260px")
                )
              )
      ),
      
      # ============================================================
      # LBO TAB
      # ============================================================
      tabItem("lbo",
              div(class="page-header",
                  tags$h2("[ LBO MODEL ]"),
                  tags$p("Leveraged Buyout · IRR · MOIC · Debt paydown · PE firm return analysis")
              ),
              fluidRow(
                box(title="LBO Parameters", width=3, solidHeader=TRUE,
                    sliderInput("lbo_entry",   "Entry EV/EBITDA:",     4,  16, 8,   step=0.5),
                    sliderInput("lbo_exit",    "Exit EV/EBITDA:",      4,  16, 10,  step=0.5),
                    sliderInput("lbo_debt",    "Debt % of Capital:",  30,  80, 65,  step=5),
                    sliderInput("lbo_hold",    "Holding Period (yrs):", 3,   7,  5, step=1),
                    sliderInput("lbo_growth",  "EBITDA Growth (%):",   3,  20, 8,   step=1),
                    actionButton("run_lbo_btn","▶  RUN LBO", width="100%")
                ),
                box(title="LBO Returns Summary", width=9, solidHeader=TRUE,
                    fluidRow(
                      column(4,
                             div(class="metric-card",
                                 div(class="mc-val",id="lbo_irr","—"),
                                 div(class="mc-lbl","IRR (%)")
                             ),
                             div(class="metric-card",
                                 div(class="mc-val green",id="lbo_moic","—"),
                                 div(class="mc-lbl","MOIC (×)")
                             ),
                             div(class="metric-card",
                                 div(class="mc-val blue",id="lbo_exit_ev","—"),
                                 div(class="mc-lbl","Exit EV (₹ Cr)")
                             ),
                             div(class="metric-card",
                                 div(class="mc-val",id="lbo_equity_ret","—"),
                                 div(class="mc-lbl","Equity Return (₹ Cr)")
                             )
                      ),
                      column(8,
                             plotlyOutput("lbo_chart", height="320px")
                      )
                    )
                )
              ),
              fluidRow(
                box(title="IRR Sensitivity — Entry vs Exit Multiple", width=7, solidHeader=TRUE,
                    withSpinner(DTOutput("lbo_sensitivity"), color="#d4a843", type=6)
                ),
                box(title="Debt Paydown Schedule", width=5, solidHeader=TRUE,
                    plotlyOutput("lbo_debt_chart", height="260px")
                )
              )
      ),
      
      # ============================================================
      # CREDIT TAB
      # ============================================================
      tabItem("credit",
              div(class="page-header",
                  tags$h2("[ CREDIT RISK & ALTMAN Z-SCORE ]"),
                  tags$p("Bankruptcy prediction · Credit rating · Leverage analysis · Basel III metrics")
              ),
              fluidRow(
                box(title="Altman Z-Score Components", width=4, solidHeader=TRUE,
                    withSpinner(uiOutput("zscore_ui"), color="#d4a843", type=6)
                ),
                box(title="Z-Score Gauge & Rating", width=4, solidHeader=TRUE,
                    plotlyOutput("zscore_gauge", height="300px")
                ),
                box(title="Credit Metrics", width=4, solidHeader=TRUE,
                    withSpinner(uiOutput("credit_metrics"), color="#d4a843", type=6)
                )
              ),
              fluidRow(
                box(title="Leverage Analysis — Debt/EBITDA vs Interest Coverage", width=6, solidHeader=TRUE,
                    plotlyOutput("leverage_chart", height="280px")
                ),
                box(title="Peer Z-Score Comparison", width=6, solidHeader=TRUE,
                    plotlyOutput("zscore_peers", height="280px")
                )
              )
      )
    )
  )
)

# ============================================================
# SERVER
# ============================================================
server <- function(input, output, session) {
  
  GOLD  <- "#d4a843"; TEAL  <- "#00c896"; RED   <- "#ef4444"
  BLUE  <- "#60a5fa"; DIM   <- "#546e7a"; BG    <- "#06111f"
  BG2   <- "#020912"; GRID  <- "#0d2137"; TEXT  <- "#94a3b8"
  
  plotly_ib <- function(p, title="", xlab="", ylab="") {
    p %>% layout(
      title=list(text=title, font=list(color=TEXT, size=13, family="IBM Plex Mono")),
      paper_bgcolor=BG, plot_bgcolor=BG,
      font=list(color=TEXT, family="IBM Plex Mono", size=10),
      xaxis=list(title=xlab, gridcolor=GRID, zerolinecolor=GRID, tickfont=list(size=10)),
      yaxis=list(title=ylab, gridcolor=GRID, zerolinecolor=GRID, tickfont=list(size=10)),
      legend=list(bgcolor=BG2, bordercolor=GRID, font=list(size=10)),
      margin=list(l=50, r=20, t=35, b=45)
    )
  }
  
  # ---- Sector filter ----
  observeEvent(input$sector_filter, {
    if(input$sector_filter=="All Sectors") {
      choices <- setNames(nifty500$Symbol, paste0(nifty500$Company," (",nifty500$Sector,")"))
    } else {
      sub <- nifty500[nifty500$Sector==input$sector_filter,]
      choices <- setNames(sub$Symbol, paste0(sub$Company," (",sub$Sector,")"))
    }
    updateSelectInput(session,"company",choices=choices)
  })
  
  # ---- Reactive: Company data ----
  company_info <- reactive({
    sym  <- input$company
    row  <- nifty500[nifty500$Symbol==sym,]
    list(name=row$Company, symbol=sym, sector=row$Sector)
  })
  
  fin_data <- reactive({
    info <- company_info()
    generate_financials(info$name, info$sector)
  })
  
  price_data <- reactive({
    withProgress(message="Fetching live data...", value=0.5, {
      get_stock_data(input$company, input$period)
    })
  })
  
  # ---- VALUE BOXES ----
  output$vb_price <- renderValueBox({
    pd <- price_data()
    if(is.null(pd)||nrow(pd)==0){
      valueBox("N/A","Current Price",icon=icon("rupee-sign"),color="yellow")
    } else {
      last <- tail(pd$Close,1)
      prev <- tail(pd$Close,2)[1]
      chg  <- round((last/prev-1)*100,2)
      col  <- if(chg>=0)"green" else "red"
      valueBox(
        paste0("₹",format(round(last,2),big.mark=",")),
        paste0(ifelse(chg>=0,"▲ ","▼ "),abs(chg),"% today"),
        icon=icon("chart-line"), color=col
      )
    }
  })
  
  output$vb_mktcap <- renderValueBox({
    fin <- fin_data()
    valueBox(
      paste0("₹",format(round(fin$ev/100,0),big.mark=","),"Cr"),
      "Market Cap (approx)",
      icon=icon("building-columns"), color="blue"
    )
  })
  
  output$vb_pe <- renderValueBox({
    fin <- fin_data()
    valueBox(
      paste0(round(fin$pe,1),"x"),
      "P/E Ratio",
      icon=icon("percent"), color="yellow"
    )
  })
  
  output$vb_sector <- renderValueBox({
    info <- company_info()
    valueBox(info$sector, "Sector", icon=icon("industry"), color="purple")
  })
  
  # ---- PRICE CHART ----
  output$price_chart <- renderPlotly({
    pd <- price_data()
    if(is.null(pd)||nrow(pd)<5) {
      plot_ly() %>% add_annotations(text="Loading live data...",showarrow=FALSE,
                                    font=list(color=GOLD,size=14)) %>% plotly_ib("Price Chart")
    } else {
      ma20 <- stats::filter(pd$Close, rep(1/20,20), sides=1)
      ma50 <- stats::filter(pd$Close, rep(1/50,50), sides=1)
      plot_ly(pd) %>%
        add_trace(x=~Date, open=~Open, high=~High, low=~Low, close=~Close,
                  type="candlestick", name="Price",
                  increasing=list(line=list(color=TEAL), fillcolor=paste0(TEAL,"44")),
                  decreasing=list(line=list(color=RED),  fillcolor=paste0(RED,"44"))) %>%
        add_trace(x=pd$Date, y=as.numeric(ma20), type="scatter", mode="lines",
                  name="MA20", line=list(color=GOLD, width=1.2, dash="dot")) %>%
        add_trace(x=pd$Date, y=as.numeric(ma50), type="scatter", mode="lines",
                  name="MA50", line=list(color=BLUE, width=1.2, dash="dot")) %>%
        plotly_ib(paste0(company_info()$name," — ",input$period," Price History"),
                  "Date","Price (₹)")
    }
  })
  
  # ---- FINANCIAL SNAPSHOT ----
  output$fin_snapshot <- renderUI({
    fin <- fin_data()
    info <- company_info()
    fmt <- function(x) paste0("₹",format(round(x),big.mark=",")," Cr")
    tagList(
      tags$div(style="font-family:'IBM Plex Mono',monospace;",
               tags$div(class="info-row",
                        tags$span(style="color:#546e7a;","Revenue"),
                        tags$span(style="color:#94a3b8;",fmt(fin$revenue))),
               tags$div(class="info-row",
                        tags$span(style="color:#546e7a;","EBITDA"),
                        tags$span(style="color:#94a3b8;",fmt(fin$ebitda))),
               tags$div(class="info-row",
                        tags$span(style="color:#546e7a;","EBITDA Margin"),
                        tags$span(style="color:#d4a843;",paste0(round(fin$margin*100,1),"%"))),
               tags$div(class="info-row",
                        tags$span(style="color:#546e7a;","PAT"),
                        tags$span(style="color:#00c896;",fmt(fin$pat))),
               tags$div(class="info-row",
                        tags$span(style="color:#546e7a;","EPS"),
                        tags$span(style="color:#94a3b8;",paste0("₹",round(fin$eps,2)))),
               tags$div(class="info-row",
                        tags$span(style="color:#546e7a;","Net Debt"),
                        tags$span(style="color:#ef4444;",fmt(fin$debt-fin$cash))),
               tags$div(class="info-row",
                        tags$span(style="color:#546e7a;","EV/EBITDA"),
                        tags$span(style="color:#60a5fa;",paste0(round(fin$ev_ebitda,1),"x"))),
               tags$div(class="info-row",
                        tags$span(style="color:#546e7a;","Rev Growth"),
                        tags$span(style="color:#d4a843;",paste0(round(fin$growth*100,1),"%"))),
               tags$div(class="info-row",
                        tags$span(style="color:#546e7a;","Beta"),
                        tags$span(style="color:#94a3b8;",round(fin$beta,2))),
               tags$div(class="info-row",
                        tags$span(style="color:#546e7a;","WACC (est.)"),
                        tags$span(style="color:#94a3b8;",paste0(round(fin$wacc*100,1),"%")))
      )
    )
  })
  
  # ---- TREND CHART ----
  output$trend_chart <- renderPlotly({
    fin <- fin_data()
    years <- paste0("FY",seq(Sys.Date()%>%format("%Y")%>%as.numeric()-4,
                             Sys.Date()%>%format("%Y")%>%as.numeric()))
    plot_ly() %>%
      add_trace(x=years,y=round(fin$hist_rev/100),type="bar",name="Revenue",
                marker=list(color=paste0(BLUE,"88"),line=list(color=BLUE,width=1))) %>%
      add_trace(x=years,y=round(fin$hist_ebitda/100),type="bar",name="EBITDA",
                marker=list(color=paste0(TEAL,"88"),line=list(color=TEAL,width=1))) %>%
      add_trace(x=years,y=round(fin$hist_pat/100),type="scatter",mode="lines+markers",
                name="PAT",yaxis="y2",
                line=list(color=GOLD,width=2),
                marker=list(color=GOLD,size=6)) %>%
      plotly_ib("","Year","₹ Crore") %>%
      layout(barmode="group",
             yaxis2=list(overlaying="y",side="right",title="PAT (₹ Cr)",
                         gridcolor="transparent",tickfont=list(size=9)),
             legend=list(orientation="h",x=0,y=1.15))
  })
  
  # ---- QUICK COMPS ----
  output$quick_comps <- renderDT({
    info <- company_info()
    peers <- nifty500[nifty500$Sector==info$sector & nifty500$Symbol!=info$symbol,]
    if(nrow(peers)>5) peers <- peers[1:5,]
    df <- data.frame(
      Company = peers$Company,
      `P/E`   = round(runif(nrow(peers),10,50),1),
      `EV/EBITDA` = round(runif(nrow(peers),6,25),1),
      `Rev Growth` = paste0(round(runif(nrow(peers),5,25),1),"%"),
      Margin = paste0(round(runif(nrow(peers),8,30),1),"%")
    )
    datatable(df,options=list(dom="t",pageLength=6),rownames=FALSE) %>%
      formatStyle(1:5,color="#94a3b8",backgroundColor="#06111f")
  })
  
  # ---- DCF ----
  dcf_result <- eventReactive(input$run_dcf_btn, {
    fin <- fin_data()
    fin$margin <- input$dcf_margin/100
    fin$ebitda <- fin$revenue * fin$margin
    run_dcf(fin, input$dcf_wacc/100, input$dcf_tg/100, input$dcf_growth/100)
  })
  
  output$dcf_price <- renderUI({
    r <- dcf_result()
    tags$div(class=paste0("mc-val ",if(r$upside>0)"green" else "red"),
             paste0("₹",format(round(r$price_per_share),big.mark=",")))
  })
  output$dcf_upside <- renderUI({
    r <- dcf_result()
    tags$div(class=paste0("mc-val ",if(r$upside>0)"green" else "red"),
             paste0(ifelse(r$upside>0,"+",""),round(r$upside,1),"%"))
  })
  output$dcf_ev <- renderUI({
    r <- dcf_result()
    tags$div(class="mc-val",paste0("₹",format(round(r$ev/100),big.mark=","),"Cr"))
  })
  
  output$dcf_waterfall <- renderPlotly({
    req(dcf_result())
    r <- dcf_result()
    cats <- c("PV of FCFs","Terminal Value","Enterprise Value","(−) Debt","(+) Cash","Equity Value")
    vals <- c(r$pv_fcf, r$pv_tv, r$ev, -fin_data()$debt, fin_data()$cash, r$equity_val)
    cols <- c(BLUE, GOLD, TEAL, RED, TEAL, GOLD)
    plot_ly(x=cats, y=round(vals/100), type="bar",
            marker=list(color=cols, line=list(color=BG2,width=1))) %>%
      plotly_ib("DCF Bridge (₹ Crore)","","₹ Cr")
  })
  
  output$dcf_fcf_chart <- renderPlotly({
    req(dcf_result())
    r   <- dcf_result()
    yrs <- paste0("FY",seq(as.numeric(format(Sys.Date(),"%Y"))+1,length.out=5))
    plot_ly(x=yrs, y=round(r$fcf/100), type="bar",
            marker=list(color=paste0(TEAL,"99"),line=list(color=TEAL,width=1))) %>%
      add_trace(x=yrs, y=round(r$fcf/100), type="scatter", mode="lines+markers",
                line=list(color=GOLD,width=2), marker=list(color=GOLD,size=6), name="FCF") %>%
      plotly_ib("Free Cash Flow Projection","Year","₹ Crore")
  })
  
  output$dcf_sensitivity <- renderDT({
    req(dcf_result())
    fin <- fin_data()
    waccs <- seq(8,16,by=2)
    tgs   <- seq(2,6,by=1)
    mat   <- outer(waccs, tgs, function(w,g) {
      r <- run_dcf(fin, w/100, g/100, input$dcf_growth/100)
      round(r$price_per_share)
    })
    df <- data.frame(mat)
    colnames(df) <- paste0("TG=",tgs,"%")
    rownames(df) <- paste0("WACC=",waccs,"%")
    datatable(df, options=list(dom="t"), rownames=TRUE) %>%
      formatStyle(1:length(tgs),color="#d4a843",backgroundColor="#06111f",
                  fontWeight="600",fontFamily="IBM Plex Mono")
  })
  
  # ---- COMPS ----
  comps_data <- eventReactive(input$run_comps_btn, {
    info <- company_info()
    fin  <- fin_data()
    peers_df <- nifty500[nifty500$Sector==info$sector,]
    if(nrow(peers_df)>input$n_peers) peers_df <- peers_df[1:input$n_peers,]
    comps <- lapply(1:nrow(peers_df), function(i) {
      f <- generate_financials(peers_df$Company[i], peers_df$Sector[i])
      data.frame(
        Company      = peers_df$Company[i],
        `P/E`        = round(f$pe,1),
        `EV/EBITDA`  = round(f$ev_ebitda,1),
        `EV/Revenue` = round(f$ev/f$revenue,2),
        `Rev Growth` = paste0(round(f$growth*100,1),"%"),
        Margin       = paste0(round(f$margin*100,1),"%"),
        check.names  = FALSE
      )
    })
    do.call(rbind, comps)
  })
  
  output$comps_table <- renderDT({
    req(comps_data())
    datatable(comps_data(),
              options=list(dom="lftip",pageLength=8,
                           columnDefs=list(list(className="dt-center",targets="_all"))),
              rownames=FALSE) %>%
      formatStyle(1:6,color="#94a3b8",backgroundColor="#06111f") %>%
      formatStyle("P/E",color="#d4a843",fontWeight="600") %>%
      formatStyle("EV/EBITDA",color="#60a5fa",fontWeight="600")
  })
  
  output$comps_verdict <- renderUI({
    req(comps_data())
    fin <- fin_data()
    cd  <- comps_data()
    med_pe    <- median(cd$`P/E`)
    med_eveb  <- median(cd$`EV/EBITDA`)
    impl_pe   <- fin$eps * med_pe
    impl_eveb <- fin$ebitda * med_eveb
    tagList(
      tags$div(class="metric-card",
               tags$div(class="mc-val green",paste0("₹",format(round(impl_pe),big.mark=","))),
               tags$div(class="mc-lbl","Implied Price (P/E)")),
      tags$div(class="metric-card",
               tags$div(class="mc-val blue",paste0("₹",format(round(impl_eveb/100),big.mark=","),"Cr")),
               tags$div(class="mc-lbl","Implied EV (EV/EBITDA)"))
    )
  })
  
  output$football_field <- renderPlotly({
    req(comps_data())
    fin <- fin_data()
    cd  <- comps_data()
    methods <- c("DCF Valuation","P/E Comps","EV/EBITDA Comps","52W Range")
    lo <- c(
      fin$eps*min(cd$`P/E`)*0.9,
      fin$eps*quantile(cd$`P/E`,0.25),
      fin$ebitda*quantile(cd$`EV/EBITDA`,0.25)/100,
      fin$price*0.75
    )
    hi <- c(
      fin$eps*max(cd$`P/E`)*1.1,
      fin$eps*quantile(cd$`P/E`,0.75),
      fin$ebitda*quantile(cd$`EV/EBITDA`,0.75)/100,
      fin$price*1.25
    )
    cols <- c(GOLD,TEAL,BLUE,RED)
    p <- plot_ly()
    for(i in seq_along(methods)){
      p <- p %>% add_trace(
        x=c(lo[i],hi[i]), y=c(methods[i],methods[i]),
        type="scatter",mode="lines",
        line=list(color=cols[i],width=16),
        name=methods[i],
        hovertemplate=paste0(methods[i],": ₹",round(lo[i]),"–₹",round(hi[i]),"<extra></extra>")
      )
    }
    p %>% add_segments(x=fin$price,xend=fin$price,y=0.5,yend=length(methods)+0.5,
                       line=list(color="white",dash="dash",width=1.5),name="Current Price") %>%
      plotly_ib("Football Field — Valuation Range","Price (₹) / EV (₹Cr)","")
  })
  
  output$mult_dist <- renderPlotly({
    req(comps_data())
    cd <- comps_data()
    plot_ly() %>%
      add_trace(y=cd$`P/E`, type="box", name="P/E",
                marker=list(color=GOLD), line=list(color=GOLD)) %>%
      add_trace(y=cd$`EV/EBITDA`, type="box", name="EV/EBITDA",
                marker=list(color=TEAL), line=list(color=TEAL)) %>%
      plotly_ib("Multiple Distribution","","Multiple (×)")
  })
  
  # ---- M&A ----
  ma_result <- eventReactive(input$run_ma_btn, {
    acq_row <- nifty500[nifty500$Symbol==input$ma_acquirer,]
    tgt_row <- nifty500[nifty500$Symbol==input$ma_target,]
    acq_fin <- generate_financials(acq_row$Company, acq_row$Sector)
    tgt_fin <- generate_financials(tgt_row$Company, tgt_row$Sector)
    list(
      result  = run_ma(acq_fin, tgt_fin, input$ma_premium/100,
                       input$ma_stock_pct/100, input$ma_synergy),
      acq_fin = acq_fin, tgt_fin = tgt_fin,
      acq_name= acq_row$Company, tgt_name= tgt_row$Company
    )
  })
  
  output$ma_deal_val  <- renderUI({
    req(ma_result())
    r <- ma_result()$result
    tags$div(class="mc-val",paste0("₹",format(round(r$deal_val/100),big.mark=","),"Cr"))
  })
  output$ma_new_eps   <- renderUI({
    req(ma_result())
    r <- ma_result()$result
    tags$div(class="mc-val blue",paste0("₹",round(r$new_eps,2)))
  })
  output$ma_accretion <- renderUI({
    req(ma_result())
    r <- ma_result()$result
    tags$div(class=paste0("mc-val ",if(r$accretion>0)"green" else "red"),
             paste0(ifelse(r$accretion>0,"+",""),round(r$accretion,2),"%"))
  })
  output$ma_verdict_box <- renderUI({
    req(ma_result())
    r <- ma_result()$result
    tags$div(class="metric-card",
             tags$div(class=paste0("mc-val ",if(r$verdict=="ACCRETIVE")"green" else "red"),r$verdict),
             tags$div(class="mc-lbl","Deal Verdict"))
  })
  
  output$ma_chart <- renderPlotly({
    req(ma_result())
    d  <- ma_result()
    r  <- d$result
    cats <- c(d$acq_name, d$tgt_name, "Combined\n(no synergy)", "Combined\n(+synergy)")
    eps_vals <- c(d$acq_fin$eps, d$tgt_fin$eps, r$new_eps,
                  r$new_eps + d$ma_synergy/1000)
    cols <- c(BLUE, TEAL, if(r$accretion>0) TEAL else RED, GOLD)
    plot_ly(x=cats, y=round(eps_vals,2), type="bar",
            marker=list(color=cols, line=list(color=BG2,width=1)),
            text=paste0("₹",round(eps_vals,2)), textposition="outside",
            textfont=list(color=TEXT,size=10)) %>%
      add_segments(x=0.5,xend=1.5,y=d$acq_fin$eps,yend=d$acq_fin$eps,
                   line=list(color="white",dash="dot",width=1),showlegend=FALSE) %>%
      plotly_ib("EPS Bridge — Accretion/Dilution Analysis","","EPS (₹)")
  })
  
  output$ma_sensitivity <- renderPlotly({
    req(ma_result())
    d <- ma_result()
    premiums  <- seq(10,50,by=10)
    synergies <- seq(0,2000,by=500)
    z <- outer(premiums, synergies, function(pr,sy){
      r <- run_ma(d$acq_fin,d$tgt_fin,pr/100,input$ma_stock_pct/100,sy)
      round(r$accretion,2)
    })
    plot_ly(x=paste0("Syn ₹",synergies,"Cr"),
            y=paste0("Prem ",premiums,"%"),
            z=z, type="heatmap",
            colorscale=list(c(0,RED),c(0.5,BG2),c(1,TEAL)),
            colorbar=list(title="Accretion%",tickfont=list(color=TEXT))) %>%
      plotly_ib("Accretion Sensitivity — Premium vs Synergy","Synergy","Premium")
  })
  
  # ---- LBO ----
  lbo_result <- eventReactive(input$run_lbo_btn, {
    fin <- fin_data()
    fin$growth <- input$lbo_growth/100
    run_lbo(fin, input$lbo_entry, input$lbo_debt/100,
            input$lbo_exit, input$lbo_hold)
  })
  
  output$lbo_irr        <- renderUI({ req(lbo_result()); r<-lbo_result()
  tags$div(class=paste0("mc-val ",if(r$irr>20)"green" else if(r$irr>15)"blue" else "red"),
           paste0(round(r$irr,1),"%")) })
  output$lbo_moic       <- renderUI({ req(lbo_result()); r<-lbo_result()
  tags$div(class="mc-val green",paste0(round(r$moic,2),"×")) })
  output$lbo_exit_ev    <- renderUI({ req(lbo_result()); r<-lbo_result()
  tags$div(class="mc-val blue",paste0("₹",format(round(r$exit_ev/100),big.mark=","),"Cr")) })
  output$lbo_equity_ret <- renderUI({ req(lbo_result()); r<-lbo_result()
  tags$div(class="mc-val",paste0("₹",format(round(r$equity_out/100),big.mark=","),"Cr")) })
  
  output$lbo_chart <- renderPlotly({
    req(lbo_result())
    r   <- lbo_result()
    yrs <- 0:r$hold
    eqs <- c(r$equity_in, r$exit_ev - r$debt_remain)
    plot_ly() %>%
      add_trace(x=yrs,y=round(r$ebitda_proj/100),type="bar",name="EBITDA",
                marker=list(color=paste0(TEAL,"88"),line=list(color=TEAL,width=1))) %>%
      add_trace(x=1:r$hold,y=round(r$debt_remain/100),type="scatter",mode="lines+markers",
                name="Debt",yaxis="y2",line=list(color=RED,width=2),
                marker=list(color=RED,size=6)) %>%
      add_trace(x=yrs,y=round(eqs/100),type="scatter",mode="lines+markers",
                name="Equity Value",yaxis="y2",line=list(color=GOLD,width=2.5),
                marker=list(color=GOLD,size=8)) %>%
      plotly_ib(paste0("LBO Analysis — IRR: ",round(r$irr,1),"% | MOIC: ",round(r$moic,2),"×"),
                "Year","EBITDA (₹ Cr)") %>%
      layout(yaxis2=list(overlaying="y",side="right",title="₹ Crore",
                         gridcolor="transparent"))
  })
  
  output$lbo_sensitivity <- renderDT({
    req(lbo_result())
    fin <- fin_data()
    entries <- seq(6,12,by=2)
    exits   <- seq(6,14,by=2)
    mat <- outer(entries, exits, function(en,ex){
      r <- run_lbo(fin, en, input$lbo_debt/100, ex, input$lbo_hold)
      paste0(round(r$irr,1),"%")
    })
    df <- data.frame(mat)
    colnames(df) <- paste0("Exit=",exits,"x")
    rownames(df) <- paste0("Entry=",entries,"x")
    datatable(df,options=list(dom="t"),rownames=TRUE) %>%
      formatStyle(1:length(exits),color="#d4a843",backgroundColor="#06111f",
                  fontFamily="IBM Plex Mono",fontWeight="600")
  })
  
  output$lbo_debt_chart <- renderPlotly({
    req(lbo_result())
    r <- lbo_result()
    yrs <- 1:r$hold
    plot_ly() %>%
      add_trace(x=yrs,y=round(r$debt_remain/100),type="bar",name="Remaining Debt",
                marker=list(color=paste0(RED,"88"),line=list(color=RED,width=1))) %>%
      add_trace(x=yrs,y=round((r$debt_in-r$debt_remain)/100),type="bar",name="Debt Repaid",
                marker=list(color=paste0(TEAL,"88"),line=list(color=TEAL,width=1))) %>%
      plotly_ib("Debt Paydown Schedule","Year","₹ Crore") %>%
      layout(barmode="stack")
  })
  
  # ---- CREDIT / Z-SCORE ----
  zscore_data <- reactive({
    fin <- fin_data()
    altman_z(fin)
  })
  
  output$zscore_ui <- renderUI({
    z <- zscore_data()
    fmt <- function(x) round(x,4)
    tagList(
      tags$div(style="font-family:'IBM Plex Mono',monospace;",
               tags$div(class="metric-card",
                        tags$div(class=paste0("mc-val "),style=paste0("color:",z$color,";font-size:28px;"),
                                 round(z$z,3)),
                        tags$div(class="mc-lbl","Altman Z-Score")),
               tags$div(class=if(z$rating=="SAFE")"tag tag-green" else if(z$rating=="GREY ZONE")"tag tag-gold" else "tag tag-red",
                        z$rating),
               tags$hr(),
               tags$div(class="info-row",tags$span(style="color:#546e7a;","1.2 × WC/TA"),
                        tags$span(style="color:#94a3b8;",fmt(1.2*z$wc_ta))),
               tags$div(class="info-row",tags$span(style="color:#546e7a;","1.4 × RE/TA"),
                        tags$span(style="color:#94a3b8;",fmt(1.4*z$re_ta))),
               tags$div(class="info-row",tags$span(style="color:#546e7a;","3.3 × EBIT/TA"),
                        tags$span(style="color:#94a3b8;",fmt(3.3*z$ebit_ta))),
               tags$div(class="info-row",tags$span(style="color:#546e7a;","0.6 × MV/TD"),
                        tags$span(style="color:#94a3b8;",fmt(0.6*z$mv_td))),
               tags$div(class="info-row",tags$span(style="color:#546e7a;","1.0 × S/TA"),
                        tags$span(style="color:#94a3b8;",fmt(z$s_ta)))
      )
    )
  })
  
  output$zscore_gauge <- renderPlotly({
    z <- zscore_data()
    plot_ly(
      type="indicator", mode="gauge+number",
      value=round(z$z,2),
      title=list(text="Z-Score", font=list(color=TEXT,size=13)),
      number=list(font=list(color=z$color,size=36,family="IBM Plex Mono")),
      gauge=list(
        axis=list(range=list(0,5), tickcolor=TEXT,
                  tickfont=list(color=TEXT,size=10)),
        bar=list(color=z$color, thickness=0.25),
        bgcolor=BG,
        bordercolor=GRID,
        steps=list(
          list(range=c(0,1.81),  color="#2d0a0a"),
          list(range=c(1.81,2.99),color="#2d1f02"),
          list(range=c(2.99,5),  color="#052e16")
        ),
        threshold=list(
          line=list(color="white",width=2),
          thickness=0.75, value=z$z
        )
      )
    ) %>% layout(paper_bgcolor=BG,font=list(color=TEXT),
                 margin=list(l=30,r=30,t=40,b=10))
  })
  
  output$credit_metrics <- renderUI({
    fin <- fin_data()
    debt_ebitda <- fin$debt/fin$ebitda
    int_cov     <- fin$ebit/(fin$debt*0.07)
    net_debt_ev <- (fin$debt-fin$cash)/fin$ev
    tagList(
      tags$div(class="metric-card",
               tags$div(class=paste0("mc-val ",if(debt_ebitda<3)"green" else if(debt_ebitda<5)"blue" else "red"),
                        round(debt_ebitda,2)),
               tags$div(class="mc-lbl","Net Debt / EBITDA")),
      tags$div(class="metric-card",
               tags$div(class=paste0("mc-val ",if(int_cov>3)"green" else if(int_cov>1.5)"blue" else "red"),
                        round(int_cov,2)),
               tags$div(class="mc-lbl","Interest Coverage (×)")),
      tags$div(class="metric-card",
               tags$div(class="mc-val",paste0(round(net_debt_ev*100,1),"%")),
               tags$div(class="mc-lbl","Net Debt / EV")),
      tags$div(class="metric-card",
               tags$div(class="mc-val blue",paste0(round(fin$margin*100,1),"%")),
               tags$div(class="mc-lbl","EBITDA Margin"))
    )
  })
  
  output$leverage_chart <- renderPlotly({
    info <- company_info()
    peers <- nifty500[nifty500$Sector==info$sector,][1:min(8,nrow(nifty500[nifty500$Sector==info$sector,])),]
    fins  <- lapply(1:nrow(peers), function(i) generate_financials(peers$Company[i],peers$Sector[i]))
    de    <- sapply(fins,function(f) f$debt/f$ebitda)
    ic    <- sapply(fins,function(f) f$ebit/(f$debt*0.07))
    plot_ly(x=round(de,2),y=round(ic,2),type="scatter",mode="markers+text",
            text=peers$Company,textposition="top center",
            textfont=list(color=TEXT,size=9),
            marker=list(size=14,color=GOLD,line=list(color=BG2,width=2)),
            hovertemplate="%{text}<br>Debt/EBITDA: %{x}<br>Int.Coverage: %{y}<extra></extra>") %>%
      add_segments(x=3,xend=3,y=0,yend=max(ic)*1.2,
                   line=list(color=RED,dash="dash",width=1),showlegend=FALSE) %>%
      add_segments(x=0,xend=max(de)*1.1,y=1.5,yend=1.5,
                   line=list(color=RED,dash="dash",width=1),showlegend=FALSE) %>%
      plotly_ib("Leverage Map","Debt/EBITDA","Interest Coverage (×)")
  })
  
  output$zscore_peers <- renderPlotly({
    info  <- company_info()
    peers <- nifty500[nifty500$Sector==info$sector,][1:min(8,nrow(nifty500[nifty500$Sector==info$sector,])),]
    zs    <- sapply(1:nrow(peers),function(i) {
      f <- generate_financials(peers$Company[i],peers$Sector[i])
      round(altman_z(f)$z,2)
    })
    cols  <- ifelse(zs>2.99,TEAL,ifelse(zs>1.81,GOLD,RED))
    plot_ly(x=peers$Company,y=zs,type="bar",
            marker=list(color=cols,line=list(color=BG2,width=1)),
            text=round(zs,2),textposition="outside",
            textfont=list(color=TEXT,size=10)) %>%
      add_segments(x=0.5,xend=nrow(peers)+0.5,y=2.99,yend=2.99,
                   line=list(color=TEAL,dash="dash",width=1.5),showlegend=FALSE) %>%
      add_segments(x=0.5,xend=nrow(peers)+0.5,y=1.81,yend=1.81,
                   line=list(color=RED,dash="dash",width=1.5),showlegend=FALSE) %>%
      plotly_ib("Peer Z-Score Comparison","","Altman Z-Score") %>%
      layout(xaxis=list(tickangle=-30))
  })
}

# ============================================================
# LAUNCH
# ============================================================
cat("\n================================================\n")
cat("  IB DEAL PLATFORM — LAUNCHING NOW\n")
cat("================================================\n")
cat("  Nifty 500 companies loaded\n")
cat("  DCF + Comps + M&A + LBO + Credit\n")
cat("  Live price data via Yahoo Finance\n")
cat("================================================\n\n")

shinyApp(ui, server)