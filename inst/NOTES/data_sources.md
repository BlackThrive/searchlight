# Source register

## Verified 2026-09-16

* Re-audited all distinct self-defined ethnicity strings directly in the three
  immutable bundled archive CSVs during M4. The full label
  "Black/African/Caribbean/Black British - Any other Black/African/Caribbean background"
  occurs 58 times and maps to Other Black / Black. There are 2,077 blank and 203
  not-stated labels, which remain Unknown. `M4-classification-audit.csv` records
  every observed raw label and its counts; a regression test checks this wording.

* https://data.police.uk/data/archive/ (HTML retrieved): archives are complete
  rolling snapshots, not one-month-only datasets. The latest is `2026-07.zip`,
  covering August 2023 through July 2026, about 1.6 GB. Published checksums are
  MD5, not SHA-256. Verify published MD5 on acquisition and record a locally
  computed SHA-256 for subsequent integrity checks. Select archives by advertised
  coverage ranges, not simply one ZIP per requested month.
* https://data.police.uk/about/: stop and search begins December 2014, initially
  covering a subset of forces; records are OGL v3. Coordinates are anonymised
  snap points, so boundary errors can be systematic.
* https://data.police.uk/docs/method/stops-street/: field semantics verified
  without using the record acquisition API. Some forces provide dates without
  times, appearing at midnight; absent outcome values are unknown, not NFA.
* https://data.police.uk/api/forces: retrieved verbatim to `extdata/forces.json`.
* https://www.ons.gov.uk/census/census2021dictionary/variablesbytopic/ethnicgroupnationalidentitylanguageandreligionvariablescensus2021/ethnicgroup/classifications:
  verified the 19 substantive Census 2021 groups and 5 broad groups. Census -8
  means does not apply; it is not a police missing-ethnicity denominator.
* https://www.gov.uk/government/publications/pace-code-a-december-2023/pace-code-a-2023-accessible#annex-b-self-defined-ethnic-classification-categories:
  verified current PACE codes including W4 (Roma), O1 (Arab), A4 (Chinese).

CSV layout, ONS boundary layers, NOMIS tables and Home Office benchmark values
will be added only after direct verification at their milestone. No guessed
endpoint or unverified benchmark is treated as a source.

## Archive contents verified 2026-09-16

The complete 2026-07 ZIP was downloaded from the official archive redirect to
`https://policeuk-data.s3.amazonaws.com/archive/2026-07.zip` (1,733,868,300 bytes).
Its published MD5 was verified and its local SHA-256 retained in the sample
manifest. Member layout is `YYYY-MM/YYYY-MM-force-id-stop-and-search.csv`.
The 15 CSV column names and order in the specification match the source exactly.
The sample window is May-July 2026: West Yorkshire has 1,659, 1,466 and 1,532
records. Dyfed-Powys has no stop-and-search CSV in this three-month window; the
default is retained as instructed, with missing submissions, not zero counts.

One historical index entry labels a multipart-style hash as MD5. The index
retains that string and marks it invalid; acquisition chooses only entries with
a 32-hex-digit published MD5. A multipart ETag is not silently treated as MD5.
# M2 sources verified 2026-09-16

## ONS boundaries and lookup licences

[ONS licence guidance](https://www.ons.gov.uk/methodology/geography/licences)
confirms digital boundaries and these non-postcode, non-UPRN lookups are OGL v3.
Attribution: Source Office for National Statistics licensed under the Open
Government Licence v3. Contains OS data Crown copyright and database right 2026.

All boundary services below use layer 0 of the stable base
`https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/`, followed by
`SERVICE/FeatureServer/0`. Metadata and GeoJSON were queried live. Geometry is
BGC: generalised to 20 m and coast clipped. Queries request EPSG:4326; point
assignment and boundary distances use EPSG:27700. Full catalogue and portal
item identifiers are in `inst/extdata/ons-layers.csv`.

| Type | Verified service | Fields | Vintage |
|---|---|---|---|
| LSOA | Lower_layer_Super_Output_Areas_December_2021_Boundaries_EW_BGC_V5 | LSOA21CD, LSOA21NM | 2021-12 |
| MSOA | Middle_layer_Super_Output_Areas_December_2021_Boundaries_EW_BGC_V3 | MSOA21CD, MSOA21NM | 2021-12 |
| Ward | WD_MAY_2026_UK_BGC | WD26CD, WD26NM | 2026-05 |
| LAD | Local_Authority_Districts_May_2026_Boundaries_UK_BGC | LAD26CD, LAD26NM | 2026-05 |
| PFA | Police_Force_Areas_Dec_2024_EW_BGC | PFA24CD, PFA24NM | 2024-12 |
| Region | Regions_December_2025_Boundaries_EN_BGC | RGN25CD, RGN25NM | 2025-12 |

Region polygons cover England only. Wales must not be invented as an English
region. Latest verified PFA boundaries are December 2024 even though newer
names/codes and administrative lookup products exist. Newly advertised EU1
services carry an alpha warning recommending the existing portal until March
2027; this implementation uses the published stable services above.

Verified lookup services, each layer 0:

* `OA_LSOA_MSOA_EW_DEC_2021_LU_v3`: LSOA21CD, MSOA21CD, **LAD22CD**.
  Portal item b9ca90c10aaa4b8d9791e9859a38ca67. The title says December 2021,
  but the actual LAD field is 2022. Distinct rows acquired: 35,672.
* `LAD25_CSP25_PFA25_EW_LU`: LAD25CD, PFA25CD, PFA25NM. April 2025,
  item 8f77bda25c124e43aca5f3b90494e405. Distinct rows: 318.
* `WD26_LAD26_UK_LU`: WD26CD, LAD26CD. May 2026,
  item 7447015a1f2f4332807d7341a636f95d. E/W rows: 7,596.
* `LSOA21_BUA22_LAD22_RGN22_EW_LU_v2`: LSOA21CD, LAD22CD, RGN22CD.
  December 2022 best fit, item 0352e811ec2c4fc5917f39aea2d1b8a3.
  Distinct rows: 35,672. Administrative vintages remain separate in output.

## Census 2021 via NOMIS

Verified against the official [API documentation](https://www.nomisweb.co.uk/api/v01/help),
live dataset metadata, codelists and CSV responses. Discovery uses
`/api/v01/dataset/def.sdmx.json?search=name-*TS021*` and `?search=*RM032*`.
Mnemonic dataset URLs did not work reliably for machine metadata, so API calls
use the returned numeric IDs:

* [TS021](https://www.nomisweb.co.uk/datasets/c2021ts021) is **NM_2041_1**:
  GEOGRAPHY, C2021_ETH_20, MEASURES, FREQ, TIME. Requested measures 20100
  are counts, not percentages. Request numeric category IDs 1...19.
* [RM032](https://www.nomisweb.co.uk/datasets/c2021rm032) is **NM_2132_1**:
  GEOGRAPHY, C2021_ETH_20, C2021_AGE_6, C_SEX, MEASURES, FREQ. Metadata
  lists OA2021, LSOA2021, MSOA2021, LAD2021 and ward2021 availability.
  Live MSOA and national England/Wales requests succeeded. Sex IDs 1 female,
  2 male; ages 1 under 25, 2 age 25-34, 3 age 35-49, 4 age 50-64, 5 age 65+.
* Geography accepts ONS code strings. `GEOGRAPHY_CODE`, `C2021_ETH_20_CODE`,
  `C2021_AGE_6_CODE`, `C_SEX_CODE`, `OBS_VALUE` are verified CSV fields.
  Category CODE fields have an underscore prefix. Crucially, the numeric
  `C2021_ETH_20` field is not consistently ordered across the two tables.
  Stable code _13 is British, _1 Bangladeshi, etc.; the mapping file retains
  the exact source labels as well as harmonised labels.
* 2021 usual-resident Census exposure, reference date 21 March 2021. Each
  request is validated for expected area/category/age/sex cells. Unknown
  ethnicity is an analytical record category with no Census exposure.
* Workday and mobility exposures are deferred per the first-release scope;
  `sl_exposure()` accepts independently justified user exposure tables.

Real MSOA CSV responses are retained as offline httptest2 fixtures. Metadata
responses and original downloads remain under ignored `data-raw/sources`.

## Home Office benchmark and changelog

[Police powers and procedures, year ending March 2025](https://www.gov.uk/government/statistics/stop-and-search-arrests-and-mental-health-detentions-march-2025)
links to the verified workbook
`https://assets.publishing.service.gov.uk/media/6909d5489456634d9795fd2f/stop-search-data-tables-summary-mar25.ods`.
Table **SS_20**, row 6 headings, column 8 (one based) is All stop and searches.
The extract has 44 force totals summing to 528,582, including BTP. West Yorkshire
18,039; Dyfed-Powys 3,696. Scope includes PACE/associated legislation, s60, s47A,
s342E and s11. Financial year is April 2024-March 2025. Parsing is reproducible
with `data-raw/audit-sources.py`; counts are taken from cell contents, never
calculated from population-based rates.

The complete [data.police.uk changelog](https://data.police.uk/changelog/),
retrieved 2026-09-16, is stored compressed. The sample extract includes the
explicit missing Dyfed-Powys stop-and-search notices for May, June, July 2026.
Crime-only notices are not stop-and-search quality flags. Historical refresh
notices require resolution before they can be treated as current issues.

## Statistical backend interfaces verified 2026-09-16

* [CARBayes 6.1.1 manual](https://cran.r-project.org/web/packages/CARBayes/CARBayes.pdf)
  and installed help confirm MVS.CARleroux matrix responses/offsets, separate group
  coefficients and an unstructured between-group covariance with Leroux spatial
  precision. The numerical probe confirms area-major posterior sample ordering.
  [Lee (2013)](https://www.jstatsoft.org/article/view/v055i13) describes the package.
* [posterior R-hat](https://mc-stan.org/posterior/reference/rhat.html) and
  [bulk ESS](https://mc-stan.org/posterior/reference/ess_bulk.html) accept matrices
  with iterations in rows and independent chains in columns. Use log-ratio draws
  and retain both bulk and tail diagnostics.
* [lme4 glmer](https://lme4.github.io/lme4/reference/glmer.html) and its glmer.nb
  companion implement optional random effects. [spdep moran.mc](https://r-spatial.github.io/spdep/reference/moran.mc.html)
  supplies the exploratory residual permutation diagnostic.
* [suncalc 0.5.1 manual](https://cran.r-project.org/web/packages/suncalc/suncalc.pdf)
  confirms getSunlightTimes date/lat/lon data and explicit time-zone arguments;
  `sunset` and `dusk` are distinct fields, with dusk ending civil twilight.
* Grogger and Ridgeway (2006), doi:10.1198/016214506000000168, listed in
  [selected publications by Ridgeway](https://crim.sas.upenn.edu/people/greg-ridgeway),
  motivates the evening overlap and clock-time controls for vehicle stops.
  Searchlight documents additional assumptions for pedestrian searches.
  On 2026-09-21 the RAND RP-1253 reprint server returned HTTP 403 to automated
  checks; the university bibliography returned HTTP 200. The publisher's
  metadata independently confirms the title, year, authors and DOI.
* [Knowles, Persico and Todd (2001)](https://www.journals.uchicago.edu/doi/10.1086/318603)
  is cited for outcome-test interpretation; no package implementation was used.

## Release validation sources verified 2026-09-16

* [ONS LAD22-CSP22-PFA22 lookup](https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/LAD22_CSP22_PFA22_EW_LU/FeatureServer/0)
  item `4206337e432b45f686e29ac31d731765` supplies LAD22CD and PFA22CD for
  331 local authorities and 43 territorial forces. This matches the Census
  hierarchy vintage and avoids silently joining restructured LAD25 codes.
  Its metadata links to the [ONS geography licences](https://www.ons.gov.uk/methodology/geography/licences),
  which explicitly license non-postcode/non-UPRN lookup products under OGL v3.
* The independent reproduction downloads all 6,289 TS021 cells (331 x 19),
  validates geography completeness and normal observation status, and groups
  using published label prefixes rather than the package's mapping table.
  Raw source URLs and SHA-256 hashes are in `reproduction-manifest.json`.
* [commonmark reference](https://r-lib.r-universe.dev/commonmark/doc/manual.html)
  documents `markdown_html()` for the offline report template renderer. Reports
  use inline CSS and escaped user text, with no runtime asset downloads.
