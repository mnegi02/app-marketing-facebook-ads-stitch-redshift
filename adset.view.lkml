include: "campaign.view"

explore: adset_nested_joins_base {
  extension: required

  join: adset__bid_info {
    view_label: "Adset: Bid Info"
    sql_on: ${adset.id} =  ${adset__bid_info.id} ;;
    relationship: one_to_one
  }

  join: adset__targeting {
    view_label: "Adset: Targeting"
    sql_on: ${adset.id} =  ${adset__targeting.id} ;;
    relationship: one_to_one
  }

  join: adset__targeting__geo {
    view_label: "Adset: Targeting Geo Locations Regions"
    sql_on: ${adset.id} =  ${adset__targeting__geo.id} ;;
    relationship: one_to_many
  }

  join: adset__promoted_object {
    view_label: "Adset: Promoted Object"
    sql_on: ${adset.id} =  ${adset__promoted_object.id};;
    relationship: one_to_one
  }
}

explore: adset_fb_adapter {
  persist_with: facebook_ads_etl_datagroup
  view_name: adset
  from: adset_fb_adapter
  extends: [adset_nested_joins_base]
  hidden: yes

  join: campaign {
    from: fb_campaign
    type: left_outer
    sql_on: ${adset.campaign_id} = ${campaign.id} ;;
    relationship: many_to_one
  }

  join: account {
    from: fb_account
    type: left_outer
    sql_on: '1' = ${account.id} ;;
    relationship: many_to_one
  }
}


view: adset_fb_adapter {
  extends: [stitch_base, facebook_ads_config]
  # sql_table_name: {{ facebook_ads_schema._sql }}.facebook_adsets_{{ facebook_account_id._sql }} ;;
  sql_table_name: (
    SELECT adsets.*
    FROM {{ facebook_ads_schema._sql }}.facebook_adsets_{{ facebook_account_id._sql }} AS adsets
    INNER JOIN (
      SELECT
          MAX(_sdc_sequence) AS seq
          , id
      FROM {{ facebook_ads_schema._sql }}.facebook_adsets_{{ facebook_account_id._sql }}
      GROUP BY id
    ) AS max_adsets
    ON adsets.id = max_adsets.id
    AND adsets._sdc_sequence = max_adsets.seq
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

  dimension: bid_info {
    hidden: yes
  }

  dimension: budget_remaining {
    type: number
  }

  dimension: campaign_id {
    hidden: yes
    type: string
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

  dimension: daily_budget {
    type: number
  }

  dimension: effective_status {
    type: string
  }

  dimension: status_active {
    type: yesno
    sql: ${effective_status} = 'ACTIVE' ;;
  }

  dimension_group: end {
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
    sql: ${TABLE}.end_time ;;
  }

  dimension: lifetime_budget {
    type: number
  }

  dimension: name {
    type: string
    hidden: yes
  }

  dimension: promoted_object {
    hidden: yes
  }

  dimension_group: start {
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
    sql: ${TABLE}.start_time ;;
  }

  dimension: targeting {
    hidden: yes
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
  }
}

view: adset__bid_info {
  extends: [stitch_base, facebook_ads_config]
  derived_table: {
    sql:
      SELECT
        adset.id as id,
        adset._sdc_batched_at,
        adset._sdc_received_at,
        adset._sdc_sequence,
        adset._sdc_table_version,
        adset.bid_info__actions as actions,
        adset.bid_info__clicks as clicks,
        adset.bid_info__reach as reach
      FROM
      {{ facebook_ads_schema._sql }}.facebook_adsets_{{ facebook_account_id._sql }} as adset
      ;;
  }

  dimension: actions {
    hidden: yes
    type: string
    sql: ${TABLE}.actions ;;
  }

  dimension: id {
    hidden: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: clicks {
    hidden: yes
    type: string
    sql: ${TABLE}.clicks ;;
  }

  dimension: reach {
    hidden: yes
    type: string
    sql: ${TABLE}.reach ;;
  }
}

view: adset__targeting {
  extends: [stitch_base, facebook_ads_config]
  derived_table: {
    sql:
      SELECT
        adset.id as id,
        adset._sdc_batched_at,
        adset._sdc_received_at,
        adset._sdc_sequence,
        adset._sdc_table_version,
        adset.targeting__age_max as targeting__age_max,
        adset.targeting__age_min as targeting__age_min,
        adset.targeting__targeting_optimization as targeting_optimization,
        __targeting__friends_of_connections.name as friends_of_connections,
        __targeting__interests.name as interests,
        __targeting__flexible_spec__behaviors.name as behaviors,
        __targeting__flexible_spec__interests.name as flexible_spec_interests,
        __targeting__custom_audiences.name as custom_audiences,
        __targeting__flexible_spec__connections.name as connections,
        'NA'::text as work_employers,
        __targeting__flexible_spec__work_positions.name as work_positions,
        __targeting__device_platforms.value as device_platforms,
        __targeting__publisher_platforms.value as publisher_platforms,
        __targeting__flexible_spec__friends_of_connections.name as flexible_spec_friends_of_connections,
        'NA'::text as messenger_positions,
        'NA'::text as audience_network_positions,
        __targeting__facebook_positions.value as facebook_positions,
        __targeting__instagram_positions.value as instagram_positions
      FROM
      {{ facebook_ads_schema._sql }}.facebook_adsets_{{ facebook_account_id._sql }} as adset
      LEFT JOIN
      {{ facebook_ads_schema._sql }}."facebook_adsets_{{ facebook_account_id._sql }}__targeting__friends_of_connections"
      as __targeting__friends_of_connections ON
        adset.id = __targeting__friends_of_connections._sdc_source_key_id
      LEFT JOIN
       {{ facebook_ads_schema._sql }}."facebook_adsets_{{ facebook_account_id._sql }}__targeting__interests"
      as __targeting__interests ON
        adset.id = __targeting__interests._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_adsets_{{ facebook_account_id._sql }}__targeting__flexible_spec__behaviors"
      as __targeting__flexible_spec__behaviors ON
        adset.id = __targeting__flexible_spec__behaviors._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_adsets_{{ facebook_account_id._sql }}__targeting__flexible_spec__interests"
      as __targeting__flexible_spec__interests ON
        adset.id = __targeting__flexible_spec__interests._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_adsets_{{ facebook_account_id._sql }}__targeting__custom_audiences"
      as __targeting__custom_audiences ON
        adset.id = __targeting__custom_audiences._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_adsets_{{ facebook_account_id._sql }}__targeting__flexible_spec__connections"
      as __targeting__flexible_spec__connections ON
        adset.id = __targeting__flexible_spec__connections._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_adsets_{{ facebook_account_id._sql }}__targeting__flexible_spec__work_positions"
      as __targeting__flexible_spec__work_positions ON
        adset.id = __targeting__flexible_spec__work_positions._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_adsets_{{ facebook_account_id._sql }}__targeting__device_platforms"
      as __targeting__device_platforms ON
        adset.id = __targeting__device_platforms._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_adsets_{{ facebook_account_id._sql }}__targeting__publisher_platforms"
      as __targeting__publisher_platforms ON
        adset.id = __targeting__publisher_platforms._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_adsets_{{ facebook_account_id._sql }}__targeting__flexible_spec__friends_of_connections"
      as __targeting__flexible_spec__friends_of_connections ON
        adset.id = __targeting__flexible_spec__friends_of_connections._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_adsets_{{ facebook_account_id._sql }}__targeting__facebook_positions"
      as __targeting__facebook_positions ON
        adset.id = __targeting__facebook_positions._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_adsets_{{ facebook_account_id._sql }}__targeting__instagram_positions"
      as __targeting__instagram_positions ON
        adset.id = __targeting__instagram_positions._sdc_source_key_id

      ;;
  }

  dimension: id {
    hidden: yes
    type: string
    sql: ${TABLE}.id ;;
    primary_key: yes
  }

  dimension: friends_of_connections {
    hidden: yes
    sql: ${TABLE}.friends_of_connections ;;
  }

  dimension: behaviors {
    hidden: yes
    type: string
    sql: ${TABLE}.behaviors ;;
  }

  dimension: interests {
    hidden: yes
    type: string
    sql: ${TABLE}.interests ;;
  }

  dimension: flexible_spec_interests {
    hidden: yes
    type: string
    sql: ${TABLE}.flexible_spec_interests ;;
  }

  dimension: custom_audiences {
    hidden: yes
    type: string
    sql: ${TABLE}.custom_audiences ;;
  }

  dimension: connections {
    hidden: yes
    type: string
    sql: ${TABLE}.connections ;;
  }

  dimension: work_employers {
    hidden: yes
    type: string
    sql: ${TABLE}.work_employers ;;
  }

  dimension: work_positions {
    hidden: yes
    type: string
    sql: ${TABLE}.work_positions ;;
  }

  dimension: device_platforms {
    hidden: yes
    type: string
    sql: ${TABLE}.device_platforms ;;
  }

  dimension: publisher_platforms {
    hidden: yes
    type: string
    sql: ${TABLE}.publisher_platforms ;;
  }

  dimension: flexible_spec_friends_of_connections {
    hidden: yes
    type: string
    sql: ${TABLE}.flexible_spec_friends_of_connections ;;
  }

  dimension: messenger_positions {
    hidden: yes
    type: string
    sql: ${TABLE}.messenger_positions ;;
  }

  dimension: facebook_positions {
    hidden: yes
    type: string
    sql: ${TABLE}.facebook_positions ;;
  }

  dimension: instagram_positions {
    hidden: yes
    type: string
    sql: ${TABLE}.instagram_positions ;;
  }

  dimension: targeting_optimization {
    hidden: yes
    type: string
    sql: ${TABLE}.targeting_optimization ;;
  }
}

view: adset__promoted_object {
  extends: [stitch_base, facebook_ads_config]
  derived_table: {
    sql:
      SELECT
        adset.id as id,
        adset._sdc_batched_at,
        adset._sdc_received_at,
        adset._sdc_sequence,
        adset._sdc_table_version,
        adset.promoted_object__custom_event_type as custom_event_type,
        adset.promoted_object__page_id as page_id,
        adset.promoted_object__pixel_id as pixel_id
      FROM
      {{ facebook_ads_schema._sql }}.facebook_adsets_{{ facebook_account_id._sql }} as adset
      ;;
  }

  dimension: id {
    hidden: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: custom_event_type {
    hidden: yes
    type: string
  }

  dimension: page_id {
    hidden: yes
    type: string
  }

  dimension: pixel_id {
    hidden: yes
    type: string
  }
}


view: adset__targeting__geo {
  extends: [stitch_base, facebook_ads_config]
  derived_table: {
    sql:
      SELECT
        adset.id as id,
        adset._sdc_batched_at,
        adset._sdc_received_at,
        adset._sdc_sequence,
        adset._sdc_table_version,
        __targeting__geo_locations__cities.country as country,
        __targeting__geo_locations__cities.key as key,
        __targeting__geo_locations__cities.name as city,
        __targeting__geo_locations__cities.radius as radius,
        __targeting__geo_locations__cities.region as region,
        __targeting__geo_locations__cities.distance_unit as distance_unit,
        __targeting__geo_locations__location_types.value as location_type,
        __targeting__geo_locations__zips.region_id as region_id,
        __targeting__geo_locations__zips.primary_city_id as primary_city_id,
        __targeting__geo_locations__zips.name as zip
      FROM
      {{ facebook_ads_schema._sql }}.facebook_adsets_{{ facebook_account_id._sql }} as adset
      LEFT JOIN
      {{ facebook_ads_schema._sql }}."facebook_adsets_{{ facebook_account_id._sql }}__targeting__geo_locations__cities"
      as __targeting__geo_locations__cities ON
        adset.id = __targeting__geo_locations__cities._sdc_source_key_id
      LEFT JOIN
      {{ facebook_ads_schema._sql }}."facebook_adsets_{{ facebook_account_id._sql }}__targeting__geo_locations__location_types"
      as __targeting__geo_locations__location_types ON
        adset.id = __targeting__geo_locations__location_types._sdc_source_key_id
      LEFT JOIN
      {{ facebook_ads_schema._sql }}."facebook_adsets_{{ facebook_account_id._sql }}__targeting__geo_locations__zips"
      as __targeting__geo_locations__zips ON
        adset.id = __targeting__geo_locations__zips._sdc_source_key_id

    ;;
  }

  dimension: id {
    type: string
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension: key {
    type: string
    sql: ${TABLE}.key ;;
  }

  dimension: primary_city_id {
    type: number
    sql: ${TABLE}.primary_city_id ;;
  }

  dimension: region_id {
    type: number
    sql: ${TABLE}.region_id ;;
  }

  dimension: location_type {
    type: string
    sql: ${TABLE}.location_type ;;
  }

  dimension: distance_unit {
    type: string
    sql: ${TABLE}.distance_unit ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: radius {
    type: number
    sql: ${TABLE}.radius ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: zip {
    type: string
    sql: ${TABLE}.zip ;;
  }
}
