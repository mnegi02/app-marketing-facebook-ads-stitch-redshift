include: "account.view.lkml"
include: "stitch_base.view.lkml"

explore: campaign_nested_joins_base {
  extension: required

  join: campaign__ads__data {
    view_label: "campaign: Ads Data"
    sql_on: ${campaign.id} = ${campaign__ads__data.id} ;;
    relationship: one_to_many
  }

  join: campaign__ads {
    view_label: "campaign: Ads"
    sql_on: ${campaign.id} = ${campaign__ads.id} ;;
    relationship: one_to_one
  }
}

explore: campaign_fb_adapter {
  persist_with: facebook_ads_etl_datagroup
  view_name: campaign
  from: campaign_fb_adapter
  extends: [campaign_nested_joins_base]
  hidden: yes

  join: account {
    from: fb_account
    type: left_outer
    sql_on: '1' = ${account.id} ;;
    relationship: many_to_one
  }
}

view: campaign_fb_adapter {
  extends: [stitch_base, facebook_ads_config]
  # sql_table_name: {{ facebook_ads_schema._sql }}.facebook_campaigns_{{ facebook_account_id._sql }} ;;
  sql_table_name: (
    SELECT campaigns.*
    FROM {{ facebook_ads_schema._sql }}.facebook_campaigns_{{ facebook_account_id._sql }} AS campaigns
    INNER JOIN (
      SELECT
        MAX(_sdc_sequence) AS seq
        , id
      FROM {{ facebook_ads_schema._sql }}.facebook_campaigns_{{ facebook_account_id._sql }}
      GROUP BY id
    ) AS max_campaigns
    ON campaigns.id = max_campaigns.id
    AND campaigns._sdc_sequence = max_campaigns.seq
  ) ;;


  dimension: id {
    hidden: yes
    primary_key: yes
    type: string
  }

  dimension: account_id {
    hidden: yes
    type: string
  }

  dimension: ads {
    hidden: yes
  }

  dimension: buying_type {
    type: string
  }

  dimension: effective_status {
    type: string
    hidden: yes
  }

  dimension: status_active {
    type: yesno
    sql: ${effective_status} = 'ACTIVE' ;;
  }

  dimension: name {
    type: string
    hidden: yes
  }

  dimension: objective {
    type: string
    hidden: yes
  }

  dimension: start_date {
    sql: 'NA'::text ;;
  }

  dimension_group: updated {
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
    sql: ${TABLE}.updated_time ;;
  }
}

view: campaign__ads__data {
  extends: [stitch_base, facebook_ads_config]
  sql_table_name: {{ facebook_ads_schema._sql }}."facebook_campaigns_{{ facebook_account_id._sql }}__ads__data" ;;
  dimension: id {
    hidden: yes
    primary_key: yes
    type: string
  }
}

view: campaign__ads {
  derived_table: {
    sql:
      SELECT
        0 as id,
        'NA'::text as data;;
  }
  dimension: data {
    hidden: yes
  }

  dimension: id {
    hidden: yes
  }
}
