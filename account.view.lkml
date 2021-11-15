explore: account_fb_adapter {
  persist_with: facebook_ads_etl_datagroup
  hidden: yes
}
view: account_fb_adapter {
  sql_table_name: (
    SELECT
      '1' as id,
      'Facebook' as name,
      'ACTIVE' as account_status,
      CURRENT_DATE as created_time,
      'USD' as currency,
      0 as min_campaign_group_spend_cap,
      0 as min_daily_budget,
      0 as timezone_id,
      'NA' as timezone_name,
      0 as timezone_offset_hours_utc
  ) ;;
  dimension: id {
    hidden: yes
  }

  dimension: account_status {
    hidden: yes
    type: string
  }

  dimension: status_active {
    hidden: yes
    type: yesno
    sql: ${account_status} = 'ACTIVE' ;;
  }

  dimension_group: created {
    hidden: yes
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_time ;;
  }

  dimension: currency {
    hidden: yes
    type: string
    sql: ${TABLE}.currency ;;
  }

  dimension: min_campaign_group_spend_cap {
    hidden: yes
    type: number
    sql: ${TABLE}.min_campaign_group_spend_cap ;;
  }

  dimension: min_daily_budget {
    hidden: yes
    type: number
    sql: ${TABLE}.min_daily_budget ;;
  }

  dimension: name {
    type: string
    hidden: yes
  }

  dimension: timezone_id {
    hidden: yes
    type: number
    sql: ${TABLE}.timezone_id ;;
  }

  dimension: timezone_name {
    hidden: yes
    type: string
    sql: ${TABLE}.timezone_name ;;
  }

  dimension: timezone_offset_hours_utc {
    hidden: yes
    type: number
    sql: ${TABLE}.timezone_offset_hours_utc ;;
  }
}
