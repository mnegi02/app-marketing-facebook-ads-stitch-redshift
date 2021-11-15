include: "ad_transformations_base.view"
include: "ad_metrics_base.view"
include: "stitch_base.view.lkml"

view: insights_base {
  extension: required
  extends: [stitch_base, ad_transformations_base, ad_metrics_fb_base_adapter]

  dimension: primary_key {
    hidden: yes
    primary_key: yes
    sql: CAST(${_date} AS VARCHAR)
      || '|'::text || ${campaign_id}
      || '|'::text || ${adset_id}
      || '|'::text || ${ad_id}
      || '|'::text || ${breakdown} ;;
  }

  dimension: breakdown {
    hidden: yes
    sql: '1' ;;
  }

  dimension: frequency {
    hidden: yes
    type: number
  }

  dimension: reach {
    hidden: yes
    type: number
  }

  dimension: spend {
    hidden: yes
    type: number
  }

  dimension: impressions {
    hidden: yes
    type: number
  }

  dimension: clicks {
    hidden: yes
    type: number
  }

  dimension: total_actions {
    hidden: yes
    type: number
  }

  dimension: total_action_value {
    hidden: yes
    type: number
  }

  dimension: account_id {
    hidden:  yes
    type: string
  }

  dimension: account_name {
    type: string
  }

  dimension: actions {
    hidden: yes
  }

  dimension: ad_id {
    hidden:  yes
    type: string
  }

  dimension: ad_name {
    type: string
  }

  dimension: adset_id {
    hidden:  yes
    type: string
  }

  dimension: adset_name {
    type: string
  }

  dimension: campaign_id {
    hidden:  yes
    type: string
  }

  dimension: campaign_name {
    type: string
  }

  dimension: canvas_avg_view_percent {
    hidden: yes
    type: number
  }

  dimension: canvas_avg_view_time {
    hidden: yes
    type: number
  }

  dimension: cost_per_inline_link_click {
    hidden: yes
    type: number
  }

  dimension: cost_per_inline_post_engagement {
    hidden: yes
    type: number
  }

  dimension: cost_per_total_action {
    hidden: yes
    type: number
  }

  dimension: cost_per_unique_click {
    hidden: yes
    type: number
  }

  dimension: cost_per_unique_inline_link_click {
    hidden: yes
    type: number
  }

  dimension: cpc {
    hidden: yes
    type: number
  }

  dimension: cpm {
    hidden: yes
    type: number
  }

  dimension: cpp {
    hidden: yes
    type: number
  }

  dimension: ctr {
    hidden: yes
    type: number
  }

  dimension: _date {
    hidden: yes
    type: date_raw
    sql: CAST(${TABLE}.date_start AS DATE) ;;
  }

  dimension_group: date_start {
    hidden: yes
    type: time
    label: "Start"
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    allow_fill: no
  }

  dimension_group: date_stop {
    hidden:  yes
    label: "Stop"
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
  }

  dimension: inline_link_click_ctr {
    hidden: yes
    type: number
  }

  dimension: inline_link_clicks {
    hidden: yes
    type: number
  }

  dimension: inline_post_engagement {
    hidden: yes
    type: number
  }

  dimension: objective {
    hidden: yes
    type: string
  }

  dimension: social_clicks {
    hidden: yes
    type: number
  }

  dimension: social_impressions {
    hidden: yes
    type: number
  }

  dimension: social_reach {
    hidden: yes
    type: number
  }

  dimension: total_unique_actions {
    hidden: yes
    type: number
  }

  dimension: unique_actions {
    hidden: yes
  }

  dimension: unique_clicks {
    hidden: yes
    type: number
  }

  dimension: unique_ctr {
    hidden: yes
    type: number
  }

  dimension: unique_inline_link_click_ctr {
    hidden: yes
    type: number
  }

  dimension: unique_inline_link_clicks {
    hidden: yes
    type: number
  }

  dimension: unique_link_clicks_ctr {
    hidden: yes
    type: number
  }

  dimension: unique_social_clicks {
    hidden: yes
    type: number
  }

  dimension: video_10_sec_watched_actions {
    hidden: yes
  }

  dimension: video_15_sec_watched_actions {
    hidden: yes
  }

  dimension: video_30_sec_watched_actions {
    hidden: yes
  }

  dimension: video_p100_watched_actions {
    hidden: yes
  }

  dimension: video_p25_watched_actions {
    hidden: yes
  }

  dimension: video_p50_watched_actions {
    hidden: yes
  }

  dimension: video_p75_watched_actions {
    hidden: yes
  }

  dimension: video_p95_watched_actions {
    hidden: yes
  }

  dimension: website_ctr {
    hidden: yes
  }
}

view: ads_insights__actions_website_base {
  extends: [ad_metrics_conversion_fb_base_adapter]
  extension: required
  dimension: action_destination {
    hidden: yes
    type: string
  }

  dimension: action_target_id {
    hidden: yes
    type: string
  }

  dimension: action_type {
    hidden: yes
    type: string
  }

  dimension: value {
    hidden: yes
    type: number
  }

  dimension: offsite_conversion_value {
    hidden: yes
    type: number
    sql: CASE WHEN (${action_type} LIKE 'offsite_conversion.custom%') THEN ${value} ELSE NULL END ;;
  }
}

view: ads_insights__actions_base {
  extends: [ads_insights__actions_website_base]
  extension: required

  dimension: insight_primary_key {
    hidden: yes
    sql: CAST(${_date} AS VARCHAR)
      || '|'::text || ${campaign_id}
      || '|'::text || ${adset_id}
      || '|'::text || ${ad_id}
      || '|'::text || ${breakdown} ;;
  }

  dimension: action_primary_key {
    hidden: yes
    primary_key: yes
    sql: CAST(${_date} AS VARCHAR)
      || '|'::text || ${ad_id}
      || '|'::text || ${adset_id}
      || '|'::text || ${campaign_id}
      || '|'::text || ${action_type}
      || '|'::text || ${action_destination}
      || '|'::text || ${action_target_id}
      || '|'::text || ${breakdown} ;;
  }

  dimension: breakdown {
    hidden: yes
    sql: '1' ;;
  }

  dimension: _1d_click {
    hidden: yes
    type: number
  }

  dimension: _1d_view {
    hidden: yes
    type: number
  }

  dimension: _28d_click {
    hidden: yes
    type: number
  }

  dimension: _28d_view {
    hidden: yes
    type: number
  }

  dimension: _7d_click {
    hidden: yes
    type: number
  }

  dimension: _7d_view {
    hidden: yes
    type: number
  }
}

view: ads_insights__video_30_sec_watched_actions {
  extends: [stitch_base, facebook_ads_config, ads_insights__actions_base]
  derived_table: {
    sql:
      SELECT
        video_10_sec_watched_actions.*
      FROM
      {{ facebook_ads_schema._sql }}."facebook_ads_insights_{{ facebook_account_id._sql }}__video_10_sec_watched_actions" as video_10_sec_watched_actions
      ;;
  }

  dimension: ad_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_ad_id ;;
  }

  dimension: adset_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_adset_id ;;
  }

  dimension: campaign_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_campaign_id ;;
  }

  dimension_group: date_start {
    hidden: yes
    type: time
    label: "Start"
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    allow_fill: no
    sql: ${TABLE}._sdc_source_key_date_start ;;
  }

}

view: ads_insights__video_p75_watched_actions {
  extends: [stitch_base, facebook_ads_config, facebook_ads_config]
  derived_table: {
    sql:
      SELECT
        video_p75_watched_actions.*
      FROM
      {{ facebook_ads_schema._sql }}."facebook_ads_insights_{{ facebook_account_id._sql }}__video_p75_watched_actions" as video_p75_watched_actions
      ;;
  }

  dimension: ad_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_ad_id ;;
  }

  dimension: adset_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_adset_id ;;
  }

  dimension: campaign_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_campaign_id ;;
  }

  dimension_group: date_start {
    hidden: yes
    type: time
    label: "Start"
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    allow_fill: no
    sql: ${TABLE}._sdc_source_key_date_start ;;
  }
}

view: ads_insights__video_p95_watched_actions {
  extends: [stitch_base, facebook_ads_config, ads_insights__actions_base]
  derived_table: {
    sql:
      SELECT
        video_p95_watched_actions.*
      FROM
      {{ facebook_ads_schema._sql }}."facebook_ads_insights_{{ facebook_account_id._sql }}__video_p95_watched_actions" as video_p95_watched_actions
      ;;
  }

  dimension: ad_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_ad_id ;;
  }

  dimension: adset_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_adset_id ;;
  }

  dimension: campaign_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_campaign_id ;;
  }

  dimension_group: date_start {
    hidden: yes
    type: time
    label: "Start"
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    allow_fill: no
    sql: ${TABLE}._sdc_source_key_date_start ;;
  }
}

view: ads_insights__actions {
  extends: [stitch_base, facebook_ads_config, ads_insights__actions_base]
  derived_table: {
    sql:
      SELECT
        CAST(actions._sdc_batched_at AS DATE),
        CAST(actions._sdc_received_at AS DATE),
        actions._sdc_sequence,
        actions._sdc_source_key_ad_id,
        actions._sdc_source_key_adset_id,
        actions._sdc_source_key_campaign_id,
        actions._sdc_source_key_date_start,
        actions._sdc_table_version,
        actions.action_target_id,
        (CASE WHEN (actions.action_type LIKE 'offsite_conversion.custom%') THEN 'offsite_conversion.custom' ELSE actions.action_type END),
        actions.action_destination,
        SUM(actions.value) as value,
        SUM(actions."1d_click") as "1d_click",
        SUM(actions."1d_view") as "1d_view",
        SUM(actions."28d_click") as "28d_click",
        SUM(actions."28d_view") as "28d_view",
        SUM(actions."7d_click") as "7d_click",
        SUM(actions."7d_view") as "7d_view"
      FROM {{ actions.facebook_ads_schema._sql }}."facebook_ads_insights_{{ actions.facebook_account_id._sql }}__actions" as actions
      INNER JOIN (
        SELECT
        MAX(_sdc_sequence) AS seq
        , _sdc_source_key_ad_id as ad_id
        , _sdc_source_key_adset_id as adset_id
        , _sdc_source_key_campaign_id as campaign_id
        , _sdc_source_key_date_start as date_start
        , action_type
        , action_target_id
        , action_destination
        FROM {{ actions.facebook_ads_schema._sql }}."facebook_ads_insights_{{ actions.facebook_account_id._sql }}__actions"
        GROUP BY
          ad_id,
          adset_id,
          campaign_id,
          date_start,
          action_type,
          action_target_id,
          action_destination
      ) AS max_ads_actions
      ON actions._sdc_source_key_ad_id = max_ads_actions.ad_id
      AND actions._sdc_source_key_adset_id = max_ads_actions.adset_id
      AND actions._sdc_source_key_campaign_id = max_ads_actions.campaign_id
      AND actions._sdc_source_key_date_start = max_ads_actions.date_start
      AND actions._sdc_sequence = max_ads_actions.seq
      AND actions.action_type = max_ads_actions.action_type
      AND actions.action_target_id = max_ads_actions.action_target_id
      AND actions.action_destination = max_ads_actions.action_destination
      GROUP BY
        1,2,3,4,5,6,7,8,9,10,11
      ;;
  }

  dimension: ad_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_ad_id ;;
  }

  dimension: adset_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_adset_id ;;
  }

  dimension: campaign_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_campaign_id ;;
  }

  dimension: action_target_id {
    hidden:  yes
    type: string
    sql: ${TABLE}.action_target_id ;;
  }

  dimension_group: date_start {
    hidden: yes
    type: time
    label: "Start"
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    allow_fill: no
    sql: CAST(${TABLE}._sdc_source_key_date_start AS DATE) ;;
  }

  dimension: _date {
    type: date_raw
    sql: CAST(${TABLE}._sdc_source_key_date_start AS DATE) ;;
  }

  dimension: action_type {
    hidden: no
  }

  dimension: action_destination {
    hidden: no
  }
}

view: ads_insights__website_ctr {
  extends: [stitch_base, facebook_ads_config, ads_insights__actions_website_base]
  derived_table: {
    sql:
      SELECT
        website_ctr.*
      FROM
      {{ facebook_ads_schema._sql }}."facebook_ads_insights_{{ facebook_account_id._sql }}__website_ctr" as website_ctr
      ;;
  }
}

view: ads_insights__video_15_sec_watched_actions {
  extends: [stitch_base, facebook_ads_config, ads_insights__actions_base]
  derived_table: {
    sql:
      SELECT
        video_15_sec_watched_actions.*
      FROM
      {{ facebook_ads_schema._sql }}."facebook_ads_insights_{{ facebook_account_id._sql }}__video_15_sec_watched_actions" as video_15_sec_watched_actions
      ;;
  }

  dimension: ad_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_ad_id ;;
  }

  dimension: adset_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_adset_id ;;
  }

  dimension: campaign_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_campaign_id ;;
  }

  dimension_group: date_start {
    hidden: yes
    type: time
    label: "Start"
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    allow_fill: no
    sql: ${TABLE}._sdc_source_key_date_start ;;
  }
}

view: ads_insights__video_10_sec_watched_actions {
  extends: [stitch_base, facebook_ads_config, ads_insights__actions_base]
  derived_table: {
    sql:
      SELECT
        video_10_sec_watched_actions.*
      FROM
      {{ facebook_ads_schema._sql }}."facebook_ads_insights_{{ facebook_account_id._sql }}__video_10_sec_watched_actions" as video_10_sec_watched_actions
      ;;
  }

  dimension: ad_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_ad_id ;;
  }

  dimension: adset_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_adset_id ;;
  }

  dimension: campaign_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_campaign_id ;;
  }

  dimension_group: date_start {
    hidden: yes
    type: time
    label: "Start"
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    allow_fill: no
    sql: ${TABLE}._sdc_source_key_date_start ;;
  }
}

view: ads_insights__unique_actions {
  extends: [stitch_base, facebook_ads_config, ads_insights__actions_base]
  derived_table: {
    sql:
      SELECT
        unique_actions.*
      FROM
      {{ facebook_ads_schema._sql }}."facebook_ads_insights_{{ facebook_account_id._sql }}__unique_actions" as unique_actions
      ;;
  }

  dimension: ad_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_ad_id ;;
  }

  dimension: adset_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_adset_id ;;
  }

  dimension: campaign_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_campaign_id ;;
  }

  dimension_group: date_start {
    hidden: yes
    type: time
    label: "Start"
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    allow_fill: no
    sql: ${TABLE}._sdc_source_key_date_start ;;
  }

}

view: ads_insights__video_p25_watched_actions {
  extends: [stitch_base, facebook_ads_config, ads_insights__actions_base]
  derived_table: {
    sql:
      SELECT
        video_p25_watched_actions.*
      FROM
      {{ facebook_ads_schema._sql }}."facebook_ads_insights_{{ facebook_account_id._sql }}__video_p25_watched_actions" as video_p25_watched_actions
      ;;
  }

  dimension: ad_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_ad_id ;;
  }

  dimension: adset_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_adset_id ;;
  }

  dimension: campaign_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_campaign_id ;;
  }

  dimension_group: date_start {
    hidden: yes
    type: time
    label: "Start"
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    allow_fill: no
    sql: ${TABLE}._sdc_source_key_date_start ;;
  }
}

view: ads_insights__video_p100_watched_actions {
  extends: [stitch_base, facebook_ads_config, ads_insights__actions_base]
  derived_table: {
    sql:
      SELECT
        video_p100_watched_actions.*
      FROM
      {{ facebook_ads_schema._sql }}."facebook_ads_insights_{{ facebook_account_id._sql }}__video_p100_watched_actions" as video_p100_watched_actions
      ;;
  }

  dimension: ad_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_ad_id ;;
  }

  dimension: adset_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_adset_id ;;
  }

  dimension: campaign_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_campaign_id ;;
  }

  dimension_group: date_start {
    hidden: yes
    type: time
    label: "Start"
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    allow_fill: no
    sql: ${TABLE}._sdc_source_key_date_start ;;
  }
}

view: ads_insights__video_p50_watched_actions {
  extends: [stitch_base, facebook_ads_config, ads_insights__actions_base]
  derived_table: {
    sql:
      SELECT
        video_p50_watched_actions.*
      FROM
      {{ facebook_ads_schema._sql }}."facebook_ads_insights_{{ facebook_account_id._sql }}__video_p50_watched_actions" as video_p50_watched_actions
      ;;
  }

  dimension: ad_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_ad_id ;;
  }

  dimension: adset_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_adset_id ;;
  }

  dimension: campaign_id {
    hidden:  yes
    type: string
    sql: ${TABLE}._sdc_source_key_campaign_id ;;
  }

  dimension_group: date_start {
    hidden: yes
    type: time
    label: "Start"
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    allow_fill: no
    sql: ${TABLE}._sdc_source_key_date_start ;;
  }
}

view: ads_insights__relevance_score {
  extends: [stitch_base, facebook_ads_config]
  sql_table_name: {{ facebook_ads_schema._sql }}.facebook_ads_insights_{{ facebook_account_id._sql }} ;;

  dimension: ad_id {
    hidden:  yes
    type: string
  }

  dimension: adset_id {
    hidden:  yes
    type: string
  }

  dimension: campaign_id {
    hidden:  yes
    type: string
  }

  dimension: negative_feedback {
    hidden: yes
    type: string
    sql: ${TABLE}.relevance_score__negative_feedback ;;
  }

  dimension: positive_feedback {
    hidden: yes
    type: string
    sql: ${TABLE}.relevance_score__positive_feedback ;;
  }

  dimension: score {
    hidden: yes
    type: number
    sql: ${TABLE}.relevance_score__score ;;
  }

  dimension: status {
    hidden: yes
    type: string
    sql: ${TABLE}.relevance_score__status ;;
  }
}
