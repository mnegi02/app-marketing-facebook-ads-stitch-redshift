view: ad_transformations_base {
  extension: required

  dimension: conversions {
    hidden: yes
    type: number
    sql: ${actions.offsite_conversion_value} ;;
  }

  dimension: conversionvalue {
    hidden: yes
    type: number
    sql: ${total_action_value};;
  }

  dimension: cost {
    hidden: yes
    type: number
    sql: ${spend} ;;
  }
}
