include: "adcreative.view"
include: "adset.view"

explore: ad_nested_joins_base {
  extension: required

  join: ad__conversion_specs {
    view_label: "Ad: Conversion Specs"
    sql_on: ${ad.id} = ${ad__conversion_specs.id} ;;
    relationship: one_to_many
  }

  join: ad__bid_info {
    view_label: "Ad: Bid Info"
    sql_on: ${ad.id} = ${ad__bid_info.id};;
    relationship: one_to_one
  }

  join: ad__recommendations {
    view_label: "Ad: Recommendations"
    sql_on: ${ad.id} = ${ad__recommendations.id} ;;
    relationship: one_to_one
  }

  join: ad__targeting {
    view_label: "Ad: Targeting"
    sql_on: ${ad.id} = ${ad__targeting.id}  ;;
    relationship: one_to_one
  }

  join: ad__targeting__geo {
    view_label: "Ad: Targeting Geo"
    sql_on: ${ad.id} = ${ad__targeting__geo.id};;
    relationship: one_to_one
  }
}

explore: ad_fb_adapter {
  persist_with: facebook_ads_etl_datagroup
  extends: [ad_nested_joins_base]
  view_name: ad
  from: ad_fb_adapter
  hidden: yes

  join: adcreative {
    from: fb_adcreative
    type: left_outer
    sql_on: ${ad.creative_id} = ${adcreative.id} ;;
    relationship: one_to_one
  }

  join: adset {
    from: fb_adset
    type: left_outer
    sql_on: ${ad.adset_id} = ${adset.id} ;;
    relationship: many_to_one
  }

  join: campaign {
    from: fb_campaign
    type: left_outer
    sql_on: ${ad.campaign_id} = ${campaign.id} ;;
    relationship: many_to_one
  }

  join: account {
    from: fb_account
    type: left_outer
    sql_on: '1' = ${account.id} ;;
    relationship: many_to_one
  }
}

view: ad_fb_adapter {
  extends: [stitch_base, facebook_ads_config]
  # sql_table_name: {{ facebook_ads_schema._sql }}.facebook_ads_{{ facebook_account_id._sql }} ;;
  sql_table_name: (
    SELECT ads.*
    FROM {{ facebook_ads_schema._sql }}.facebook_ads_{{ facebook_account_id._sql }} AS ads
    INNER JOIN (
      SELECT
        MAX(_sdc_sequence) AS seq
        , id
      FROM {{ facebook_ads_schema._sql }}.facebook_ads_{{ facebook_account_id._sql }}
      GROUP BY id
      ) AS max_ads
    ON ads.id = max_ads.id
    AND ads._sdc_sequence = max_ads.seq
  ) ;;

  dimension: id {
    hidden: yes
    primary_key: yes
    type: string
  }

  dimension: account_id {
    type: string
    hidden: yes
  }

  dimension: adset_id {
    type: string
    hidden: yes
  }

  dimension: bid_amount {
    type: number
  }

  dimension: bid_info {
    hidden: yes
  }

  dimension: bid_type {
    type: string
  }

  dimension: campaign_id {
    type: string
    hidden: yes
  }

  dimension: conversion_specs {
    hidden: yes
  }

  dimension_group: created {
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

  dimension: creative_id {
    type: string
    hidden: yes
  }

  dimension: effective_status {
    type: string
  }

  dimension: last_updated_by_app_id {
    type: string
    hidden: yes
  }

  dimension: name {
    type: string
    hidden: yes
  }

  dimension: recommendations {
    hidden: yes
    sql: ${TABLE}.recommendations ;;
  }

  dimension: source_ad_id {
    type: string
    hidden: yes
  }

  dimension: status {
    type: string
  }

  dimension: status_active {
    type: yesno
    sql: ${status} = 'ACTIVE' ;;
  }

  dimension: targeting {
    hidden: yes
  }

  dimension: tracking_specs {
    hidden: yes
  }

  dimension_group: updated {
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

view: ad__conversion_specs {
  extends: [stitch_base, facebook_ads_config]
  derived_table: {
    sql:
      SELECT
        ad.id as id,
        ad._sdc_batched_at,
        ad._sdc_received_at,
        ad._sdc_sequence,
        ad._sdc_table_version,
        __conversion_specs__action_type.value as action_type,
        __conversion_specs__conversion_id.value as conversion_id,
        __conversion_specs__page.value as page,
        __conversion_specs__post.value as post,
        __conversion_specs__post_wall.value as post_wall
      FROM
      {{ facebook_ads_schema._sql }}.facebook_ads_{{ facebook_account_id._sql }} as ad
      LEFT JOIN
      {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__conversion_specs__action.type"
      as __conversion_specs__action_type ON
        ad.id = __conversion_specs__action_type._sdc_source_key_id
      LEFT JOIN
       {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__conversion_specs__conversion_id"
      as __conversion_specs__conversion_id ON
        ad.id = __conversion_specs__conversion_id._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__conversion_specs__page"
      as __conversion_specs__page ON
        ad.id = __conversion_specs__page._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__conversion_specs__post"
      as __conversion_specs__post ON
        ad.id = __conversion_specs__post._sdc_source_key_id
      Left JOIN {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__conversion_specs__post.wall"
      as __conversion_specs__post_wall ON
        ad.id = __conversion_specs__post_wall._sdc_source_key_id
      ;;
  }

  dimension: action_type {
    hidden: yes
    type: string
    sql: ${TABLE}.action_type ;;
  }

  dimension: id {
    hidden: yes
    type: string
    sql: ${TABLE}.id ;;
    primary_key: yes
  }

  dimension: conversion_id {
    hidden: yes
    type: string
    sql: ${TABLE}.conversion_id ;;
  }

  dimension: page {
    hidden: yes
    type: string
    sql: ${TABLE}.page ;;
  }

  dimension: post {
    hidden: yes
    type: string
    sql: ${TABLE}.post ;;
  }

  dimension: post_wall {
    hidden: yes
    type: string
    sql: ${TABLE}.post_wall ;;
  }
}

view: ad__bid_info {
  extends: [stitch_base, facebook_ads_config]
  derived_table: {
    sql:
      SELECT
        ad.id as id,
        ad._sdc_batched_at,
        ad._sdc_received_at,
        ad._sdc_sequence,
        ad._sdc_table_version,
        ad.bid_info__actions as actions,
        ad.bid_info__clicks as clicks,
        ad.bid_info__reach as reach
      FROM
      {{ facebook_ads_schema._sql }}.facebook_ads_{{ facebook_account_id._sql }} as ad
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
    primary_key: yes
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

view: ad__recommendations {
  derived_table: {
    sql:
      SELECT
        0 as id,
        'NA'::text as blame_field,
        0 as code,
        'NA'::text as confidence,
        'NA'::text as importance,
        'NA'::text as message
        ;;
  }

  dimension: blame_field {
    hidden: yes
    type: string
    sql: ${TABLE}.blame_field ;;
  }

  dimension: code {
    hidden: yes
    type: number
    sql: ${TABLE}.code ;;
  }

  dimension: confidence {
    hidden: yes
    type: string
    sql: ${TABLE}.confidence ;;
  }

  dimension: importance {
    hidden: yes
    type: string
    sql: ${TABLE}.importance ;;
  }

  dimension: message {
    hidden: yes
    type: string
    sql: ${TABLE}.message ;;
  }

  dimension: id {
    hidden: yes
    type: string
    sql: ${TABLE}.id ;;
    primary_key: yes
  }
}

view: ad__targeting {
  extends: [stitch_base, facebook_ads_config]
  derived_table: {
    sql:
      SELECT
        ad.id as id,
        ad._sdc_batched_at,
        ad._sdc_received_at,
        ad._sdc_sequence,
        ad._sdc_table_version,
        ad.targeting__age_max as targeting__age_max,
        ad.targeting__age_min as targeting__age_min,
        ad.targeting__targeting_optimization as targeting_optimization,
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
      {{ facebook_ads_schema._sql }}.facebook_ads_{{ facebook_account_id._sql }} as ad
      LEFT JOIN
      {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__targeting__friends_of_connections"
      as __targeting__friends_of_connections ON
        ad.id = __targeting__friends_of_connections._sdc_source_key_id
      LEFT JOIN
       {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__targeting__interests"
      as __targeting__interests ON
        ad.id = __targeting__interests._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__targeting__flexible_spec__behaviors"
      as __targeting__flexible_spec__behaviors ON
        ad.id = __targeting__flexible_spec__behaviors._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__targeting__flexible_spec__interests"
      as __targeting__flexible_spec__interests ON
        ad.id = __targeting__flexible_spec__interests._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__targeting__custom_audiences"
      as __targeting__custom_audiences ON
        ad.id = __targeting__custom_audiences._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__targeting__flexible_spec__connections"
      as __targeting__flexible_spec__connections ON
        ad.id = __targeting__flexible_spec__connections._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__targeting__flexible_spec__work_positions"
      as __targeting__flexible_spec__work_positions ON
        ad.id = __targeting__flexible_spec__work_positions._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__targeting__device_platforms"
      as __targeting__device_platforms ON
        ad.id = __targeting__device_platforms._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__targeting__publisher_platforms"
      as __targeting__publisher_platforms ON
        ad.id = __targeting__publisher_platforms._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__targeting__flexible_spec__friends_of_connections"
      as __targeting__flexible_spec__friends_of_connections ON
        ad.id = __targeting__flexible_spec__friends_of_connections._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__targeting__facebook_positions"
      as __targeting__facebook_positions ON
        ad.id = __targeting__facebook_positions._sdc_source_key_id
      LEFT JOIN {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__targeting__instagram_positions"
      as __targeting__instagram_positions ON
        ad.id = __targeting__instagram_positions._sdc_source_key_id

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

view: ad__targeting__geo {
  extends: [stitch_base, facebook_ads_config]
  derived_table: {
    sql:
      SELECT
        ad.id as id,
        ad._sdc_batched_at,
        ad._sdc_received_at,
        ad._sdc_sequence,
        ad._sdc_table_version,
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
      {{ facebook_ads_schema._sql }}.facebook_ads_{{ facebook_account_id._sql }} as ad
      LEFT JOIN
      {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__targeting__geo_locations__cities"
      as __targeting__geo_locations__cities ON
        ad.id = __targeting__geo_locations__cities._sdc_source_key_id
      LEFT JOIN
      {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__targeting__geo_locations__location_types"
      as __targeting__geo_locations__location_types ON
        ad.id = __targeting__geo_locations__location_types._sdc_source_key_id
      LEFT JOIN
      {{ facebook_ads_schema._sql }}."facebook_ads_{{ facebook_account_id._sql }}__targeting__geo_locations__zips"
      as __targeting__geo_locations__zips ON
        ad.id = __targeting__geo_locations__zips._sdc_source_key_id

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
