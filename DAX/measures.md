# DAX Measures

## company_violation_count
```
company_violation_count = COUNT(big_chain_violations[violation_description])
```

## CompanyViolationRatio
```
DIVIDE(
  [company_violation_count],
  CALCULATE(
    [company_violation_count],
    ALLEXCEPT(
        inspections_clean,
        inspections_clean[parent_company_clean]
    ),REMOVEFLITERS('violation_mapping B'[standardized_category])
```

## AvgViolationPerBusiness
```
AvgViolationPerBusiness= DIVIDE(
  COUNT(violation_description]),
    DISTINCTCOUNT(inspection_clean[parent_company_clean]))
```

## AvgViolationsPerInspections
AvgViolationsPerInspections = DIVIDE([violation_count],[TotalInspections])

## CityViolationRatio
```
DIVIDE(
  [violation_count],
  CALCULATE(
    [violation_count],
    ALLEXCEPT(
        inspections_clean,
        inspections_clean[facility_city]
    ),REMOVEFLITERS('violations_clean'[violation_mapping.standardized_category])
```

## TotalInspections
```
TotalInspections = DISTINCTCOUNT(inspections_clean[serial_number])
```

## violation_count
```
violation_count = COUNT('violations_clean'[violation_description])
```

## AverageScore
```
AverageScore = AVERAGE('inspections_clean'[score])
```

## total_count
```
total_count = COUNT('violations_clean'[violation_description])
```
