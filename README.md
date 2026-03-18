# IB_PLATFORM
Investment Banking Deal Analysis Platform built in R (Shiny) featuring DCF, Comparable Company Analysis, M&amp;A Accretion/Dilution, LBO Modeling, and Credit Risk (Altman Z-Score) with interactive dashboards and real-time market data.
# 🏦 Investment Banking Deal Analysis Platform
---
## 📸 Preview

| Module | What it does |
|---|---|
|  Overview | Live candlestick chart, 5Y revenue trends, financial snapshot |
|  DCF Valuation | Free cash flow model, WACC sensitivity, football field chart |
|  Comps Analysis | Peer multiples, EV/EBITDA, P/E, football field valuation |
|  M&A Model | EPS accretion/dilution, deal structuring, synergy sensitivity |
|  LBO Model | IRR, MOIC, debt paydown, entry/exit multiple sensitivity |
|  Credit Risk | Altman Z-Score, leverage map, interest coverage, peer comparison |

---

## 🚀 How to Run Locally

### Step 1 — Install R and RStudio
- R: https://cran.r-project.org
- RStudio: https://posit.co/download/rstudio-desktop

### Step 2 — Open RStudio and run this

```r
# Paste IB_PLATFORM.R into RStudio
# Press Ctrl+A then Ctrl+Enter
# App launches automatically in browser
```

### Step 3 — That's it
The script auto-installs all required packages and launches the app.

---

##  Dependencies

```r
shiny
shinydashboard
plotly
DT
quantmod        # Live Nifty 500 price data from Yahoo Finance
tidyr
dplyr
scales
ggplot2
shinycssloaders
shinyWidgets
fresh
```

---

##  Project Structure

```
IB_PLATFORM.R          # Complete single-file Shiny application
README.md              # This file
```

---

##  Finance Modules — What's Under the Hood

### 1. DCF Valuation Engine
- Projects 5-year Free Cash Flow using revenue growth and EBITDA margin assumptions
- Computes Terminal Value using Gordon Growth Model
- Discounts all cash flows at WACC
- Builds EV bridge: PV of FCFs + Terminal Value − Debt + Cash = Equity Value
- Outputs intrinsic value per share and upside/downside vs current price
- **Sensitivity table**: Price vs WACC × Terminal Growth (25 scenarios)

### 2. Comparable Company Analysis (Comps)
- Auto-selects sector peers from Nifty 500 database
- Computes P/E, EV/EBITDA, EV/Revenue multiples
- Builds **Football Field chart** — the standard IB pitchbook valuation range diagram
- Shows multiple distribution via boxplot
- Outputs implied price from median peer multiples

### 3. M&A Accretion / Dilution Model
- Models any two Nifty 500 companies as acquirer and target
- Computes deal value, cash vs stock consideration
- Calculates pro forma combined EPS
- Determines if deal is **EPS accretive or dilutive**
- **Synergy sensitivity heatmap**: accretion across premium × synergy scenarios
- This is literally what analysts build their first week at Goldman Sachs

### 4. LBO Model (Leveraged Buyout)
- Models PE firm acquisition with leveraged debt structure
- Projects EBITDA over holding period
- Computes annual debt amortization and remaining debt schedule
- Calculates **IRR** and **MOIC** — the two metrics every PE firm lives by
- **IRR sensitivity table**: entry multiple × exit multiple (16 scenarios)
- Debt paydown waterfall chart

### 5. Credit Risk — Altman Z-Score
- Implements the **Altman Z-Score** model used in Basel III banking regulation
- Five-factor model: Working Capital, Retained Earnings, EBIT, Market Value, Sales
- **Z > 2.99**: Safe Zone | **1.81–2.99**: Grey Zone | **< 1.81**: Distress
- Interactive gauge visualization
- Peer leverage map: Debt/EBITDA vs Interest Coverage
- Peer Z-Score comparison bar chart

---

## Data

- **Universe**: 80+ Nifty 500 companies across 20+ sectors
- **Live Price Data**: Yahoo Finance via `quantmod` (candlestick OHLCV)
- **Financial Data**: Sector-calibrated simulation with realistic parameters
- **Sectors covered**: IT, Banking, FMCG, Pharma, Auto, Energy, Finance, Cement, Steel, Telecom, Utilities, Real Estate, Aviation, Healthcare, and more

---

##  Design

- **Theme**: Dark navy / gold — Goldman Sachs terminal aesthetic
- **Font**: IBM Plex Mono + IBM Plex Sans
- **Charts**: Fully interactive Plotly with custom dark theme
- **Color coding**: Gold (key metrics) · Teal (positive) · Red (negative) · Blue (neutral)

---

##  Interview Talking Points

If you show this in a GS / JPMorgan / Morgan Stanley interview, be ready to explain:

| Question | Answer |
|---|---|
| What is WACC? | Weighted Average Cost of Capital — discount rate reflecting risk of the firm |
| What does the football field show? | Valuation range across different methodologies — used in every IB pitchbook |
| What is accretion/dilution? | Whether a deal increases or decreases the acquirer's EPS |
| What does IRR mean in LBO? | Internal Rate of Return — annualized return the PE firm earns on equity |
| What does Altman Z-Score predict? | Probability of corporate bankruptcy within 2 years |

---

##  Possible Extensions

- Connect to real financial APIs (Bloomberg, Refinitiv, NSE)
- Add options pricing (Black-Scholes)
- Add Fama-French factor model
- Add portfolio optimization (Markowitz MPT)
- Export pitchbook PDF with one click
- Add GARCH volatility forecasting



---

## Academic References

1. **Damodaran (2012)** — Investment Valuation, 3rd Edition
2. **Altman (1968)** — Financial Ratios, Discriminant Analysis and the Prediction of Corporate Bankruptcy — *Journal of Finance*
3. **Almgren & Chriss (2001)** — Optimal Execution of Portfolio Transactions
4. **Modigliani & Miller (1958)** — The Cost of Capital, Corporation Finance and the Theory of Investment

---

##  Disclaimer

*This platform is built for educational and portfolio demonstration purposes. All financial data is simulated using sector-calibrated parameters. Live price data is sourced from Yahoo Finance. This is not financial advice.*

---

*Built with ❤️ in R · Shiny · Plotly*
