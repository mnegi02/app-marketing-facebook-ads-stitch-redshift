include: "adcreative.view"
include: "insights_base.view"

explore: ad_impressions_base_fb_adapter {
  extension: required
  view_name: fact
  label: "Impressions"
  view_label: "Impressions"

  join: account {
    from: fb_account
    type: left_outer
    sql_on: '1' = ${account.id} ;;
    relationship: many_to_one
  }

  join: campaign {
    from: fb_campaign
    type: left_outer
    sql_on: ${fact.campaign_id} = ${campaign.id} ;;
    relationship: many_to_one
  }

  join: adset {
    from: fb_adset
    type: left_outer
    sql_on: ${fact.adset_id} = ${adset.id} ;;
    relationship: many_to_one
  }

  join: ad {
    from: fb_ad
    type: left_outer
    sql_on: ${fact.ad_id} = ${ad.id} ;;
    relationship: many_to_one
  }

  join: adcreative {
    from: fb_adcreative
    type: left_outer
    sql_on: ${ad.creative_id} = ${adcreative.id} ;;
    relationship: one_to_one
  }
}

explore: ad_impressions_fb_adapter {
  persist_with: facebook_ads_etl_datagroup
  extends: [ad_impressions_base_fb_adapter]
  hidden: yes
  from: ad_impressions_fb_adapter

  join: actions {
    from: ads_insights__actions
    view_label: "Ads Insights: Actions"
    sql_on:
      ${fact.primary_key} = ${actions.insight_primary_key} AND
      ${actions.action_type} LIKE 'offsite_conversion.custom%' ;;
    relationship: one_to_one
  }
}

view: ad_impressions_fb_adapter {
  extends: [insights_base, facebook_ads_config]
  sql_table_name:
  (
    SELECT facebook_ads_ads_insights.*
    FROM {{ facebook_ads_schema._sql }}.facebook_ads_insights_{{ facebook_account_id._sql }} AS facebook_ads_ads_insights
    INNER JOIN (
      SELECT
          MAX(_sdc_sequence) AS seq
          , ad_id
          , adset_id
          , campaign_id
          , date_start
      FROM {{ facebook_ads_schema._sql }}.facebook_ads_insights_{{ facebook_account_id._sql }}
      -- fact.faceb
      GROUP BY ad_id, adset_id, campaign_id, date_start
    ) AS max_ads_insights
    ON facebook_ads_ads_insights.ad_id = max_ads_insights.ad_id
    AND facebook_ads_ads_insights.adset_id = max_ads_insights.adset_id
    AND facebook_ads_ads_insights.campaign_id = max_ads_insights.campaign_id
    AND facebook_ads_ads_insights.date_start = max_ads_insights.date_start
    AND facebook_ads_ads_insights._sdc_sequence = max_ads_insights.seq
  ) ;;

  dimension: call_to_action_clicks {
    hidden: yes
    type: number
  }

  dimension: relevance_score {
    hidden: yes
  }

  dimension: social_spend {
    hidden: yes
    type: number
  }
}

explore: ad_impressions_age_and_gender_fb_adapter {
  persist_with: facebook_ads_etl_datagroup
  extends: [ad_impressions_base_fb_adapter]
  hidden: yes
  from: ad_impressions_age_and_gender_fb_adapter

  join: actions {
    from: ads_insights_age_and_gender__actions
    view_label: "Ads Insights: Actions"
    sql_on:
      ${fact.primary_key} = ${actions.insight_primary_key} AND
      ${actions.action_type} LIKE 'offsite_conversion.custom%' ;;
    relationship: one_to_one
  }
}

view: age_and_gender_base_fb_adapter {
  extension: required

  dimension: breakdown {
    hidden: yes
    type: string
    sql: ${age} || '|'::text || ${gender_raw} ;;
  }

  dimension: age {
    type: string
  }

  dimension: gender_raw {
    hidden: yes
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: gender {
    type: string
    case: {
      when: {
        sql: ${gender_raw} = 'male' ;;
        label: "Male"
      }
      when: {
        sql: ${gender_raw} = 'female' ;;
        label: "Female"
      }
      when: {
        sql: ${gender_raw} = 'unknown';;
        label: "Unknown"
      }
      else: "Other"
    }
  }
}

view: ad_impressions_age_and_gender_fb_adapter {
  extends: [insights_base, facebook_ads_config, age_and_gender_base_fb_adapter]
  sql_table_name:
  (
  SELECT facebook_ads_ads_insights_age_and_gender.*
  FROM {{ facebook_ads_schema._sql }}.facebook_ads_insights_age_and_gender_{{ facebook_account_id._sql }} AS facebook_ads_ads_insights_age_and_gender
  INNER JOIN (
  SELECT
      MAX(_sdc_sequence) AS seq
      , ad_id
      , adset_id
      , campaign_id
      , date_start
      , age
      , gender
  FROM {{ facebook_ads_schema._sql }}.facebook_ads_insights_age_and_gender_{{ facebook_account_id._sql }}
  GROUP BY ad_id, adset_id, campaign_id, date_start, age, gender
  ) AS max_ads_insights_age_and_gender
  ON facebook_ads_ads_insights_age_and_gender.ad_id = max_ads_insights_age_and_gender.ad_id
  AND facebook_ads_ads_insights_age_and_gender.adset_id = max_ads_insights_age_and_gender.adset_id
  AND facebook_ads_ads_insights_age_and_gender.campaign_id = max_ads_insights_age_and_gender.campaign_id
  AND facebook_ads_ads_insights_age_and_gender.date_start = max_ads_insights_age_and_gender.date_start
  AND facebook_ads_ads_insights_age_and_gender.age = max_ads_insights_age_and_gender.age
  AND facebook_ads_ads_insights_age_and_gender.gender = max_ads_insights_age_and_gender.gender
  AND facebook_ads_ads_insights_age_and_gender._sdc_sequence = max_ads_insights_age_and_gender.seq
  ) ;;
}

view: ads_insights_age_and_gender__actions {
  extends: [ads_insights__actions, age_and_gender_base_fb_adapter]
  derived_table: {
    sql:
      SELECT actions.*
      FROM {{ actions.facebook_ads_schema._sql }}."facebook_ads_insights_age_and_gender_{{ actions.facebook_account_id._sql }}__actions" as actions
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
        , _sdc_source_key_age
        , _sdc_source_key_gender
        FROM {{ actions.facebook_ads_schema._sql }}."facebook_ads_insights_age_and_gender_{{ actions.facebook_account_id._sql }}__actions"
        GROUP BY ad_id, adset_id, campaign_id, date_start, action_type, action_target_id, action_destination, _sdc_source_key_age, _sdc_source_key_gender
      ) AS max_ads_actions
      ON actions._sdc_source_key_ad_id = max_ads_actions.ad_id
      AND actions._sdc_source_key_adset_id = max_ads_actions.adset_id
      AND actions._sdc_source_key_campaign_id = max_ads_actions.campaign_id
      AND actions._sdc_source_key_date_start = max_ads_actions.date_start
      AND actions._sdc_sequence = max_ads_actions.seq
      AND actions.action_type = max_ads_actions.action_type
      AND actions.action_target_id = max_ads_actions.action_target_id
      AND actions.action_destination = max_ads_actions.action_destination
      AND actions._sdc_source_key_age = max_ads_actions._sdc_source_key_age
      AND actions._sdc_source_key_gender = max_ads_actions._sdc_source_key_gender
      ;;
  }
  dimension: age {
    type: string
    sql:  ${TABLE}._sdc_source_key_age ;;
  }

  dimension: gender_raw {
    hidden: yes
    type: string
    sql: ${TABLE}._sdc_source_key_gender ;;
  }
}

explore: ad_impressions_geo_fb_adapter {
  persist_with: facebook_ads_etl_datagroup
  extends: [ad_impressions_base_fb_adapter]
  hidden: yes
  from: ad_impressions_geo_fb_adapter

  join: actions {
    from: ads_insights_geo__actions
    view_label: "Ads Insights: Actions"
    sql_on:
      ${fact.primary_key} = ${actions.insight_primary_key} AND
      ${actions.action_type} LIKE 'offsite_conversion.custom%' ;;
    relationship: one_to_one
  }
}

view: geo_base_fb_adapter {
  extension: required

  dimension: breakdown {
    sql: ${country} ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
  }
}

view: ad_impressions_geo_fb_adapter {
  extends: [insights_base, facebook_ads_config, geo_base_fb_adapter]
  sql_table_name:
  (
  SELECT facebook_ads_ads_insights_country.*
  FROM {{ facebook_ads_schema._sql }}.facebook_ads_insights_country_{{ facebook_account_id._sql }} AS facebook_ads_ads_insights_country
  INNER JOIN (
    SELECT
        MAX(_sdc_sequence) AS seq
        , ad_id
        , adset_id
        , campaign_id
        , date_start
        , country
    FROM {{ facebook_ads_schema._sql }}.facebook_ads_insights_country_{{ facebook_account_id._sql }}
    GROUP BY ad_id, adset_id, campaign_id, date_start, country
  ) AS max_ads_insights_country
  ON facebook_ads_ads_insights_country.ad_id = max_ads_insights_country.ad_id
  AND facebook_ads_ads_insights_country.adset_id = max_ads_insights_country.adset_id
  AND facebook_ads_ads_insights_country.campaign_id = max_ads_insights_country.campaign_id
  AND facebook_ads_ads_insights_country.date_start = max_ads_insights_country.date_start
  AND facebook_ads_ads_insights_country.country = max_ads_insights_country.country
  AND facebook_ads_ads_insights_country._sdc_sequence = max_ads_insights_country.seq
  ) ;;
}

view: ads_insights_geo__actions {
  extends: [ads_insights__actions, geo_base_fb_adapter]
  derived_table: {
    sql:
      SELECT actions.*, CAST('No Country Data' as TEXT) as country
      FROM {{ actions.facebook_ads_schema._sql }}."facebook_ads_insights_country_{{ actions.facebook_account_id._sql }}__actions" as actions
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
        , CAST('No Country Data' as TEXT) as country
        FROM {{ actions.facebook_ads_schema._sql }}."facebook_ads_insights_country_{{ actions.facebook_account_id._sql }}__actions"
        GROUP BY ad_id, adset_id, campaign_id, date_start, action_type, action_target_id, action_destination
      ) AS max_ads_actions
      ON actions._sdc_source_key_ad_id = max_ads_actions.ad_id
      AND actions._sdc_source_key_adset_id = max_ads_actions.adset_id
      AND actions._sdc_source_key_campaign_id = max_ads_actions.campaign_id
      AND actions._sdc_source_key_date_start = max_ads_actions.date_start
      AND actions._sdc_sequence = max_ads_actions.seq
      AND actions.action_type = max_ads_actions.action_type
      AND actions.action_target_id = max_ads_actions.action_target_id
      AND actions.action_destination = max_ads_actions.action_destination
      ;;
      # AND actions.country = max_ads_actions.country
  }
}


explore: ad_impressions_platform_and_device_fb_adapter {
  persist_with: facebook_ads_etl_datagroup
  extends: [ad_impressions_base_fb_adapter]
  hidden: yes
  from: ad_impressions_platform_and_device_fb_adapter

  join: actions {
    from: ads_insights_platform_and_device__actions
    view_label: "Ads Insights: Actions"
    sql_on:
      ${fact.primary_key} = ${actions.insight_primary_key} AND
      ${actions.action_type} LIKE 'offsite_conversion.custom%' ;;
    relationship: one_to_one
  }
}

view: platform_and_device_base_fb_adapter {
  extension: required

  dimension: breakdown {
    hidden: yes
    type: string
    sql: ${impression_device} || '|'::text || ${platform_position_raw} ;;
  }

  dimension: impression_device {
    hidden: yes
    type: string
  }

  dimension: device_type {
    type: string
    case: {
      when: {
        sql: ${impression_device} = 'desktop' ;;
        label: "Desktop"
      }
      when: {
        sql: ${impression_device} = 'iphone' OR ${impression_device} = 'android_smartphone' ;;
        label: "Mobile"
      }
      when: {
        sql: ${impression_device} = 'ipad'  OR ${impression_device} = 'android_tablet' ;;
        label: "Tablet"
      }
      else: "Other"
    }
  }

  dimension: platform_position_raw {
    hidden: yes
    type: string
    sql: ${TABLE}.platform_position ;;
  }

  dimension: platform_position {
    type: string
    label: "Position"
    sql: ${platform_position_raw} ;;
    # case: {
    #  when: {
    #    sql: ${platform_position_raw} = 'feed' AND ${publisher_platform_raw} = 'instagram' ;;
    #    label: "Feed"
    #  }
    #  when: {
    #    sql: ${platform_position_raw} = 'feed' ;;
    #    label: "News Feed"
    #  }
    #  when: {
    #    sql: ${platform_position_raw} = 'an_classic' ;;
    #    label: "Classic"
    #  }
    #  when: {
    #    sql: ${platform_position_raw} = 'all_placements' ;;
    #    label: "All"
    #  }
    #  when: {
    #    sql: ${platform_position_raw} = 'instant_article' ;;
    #    label: "Instant Article"
    #  }
    #  when: {
    #    sql: ${platform_position_raw} = 'right_hand_column' ;;
    #    label: "Right Column"
    #  }
    #  when: {
    #    sql: ${platform_position_raw} = 'rewarded_video' ;;
    #    label: "Rewarded Video"
    #  }
    #  when: {
    #    sql: ${platform_position_raw} = 'suggested_video' ;;
    #    label: "Suggested Video"
    #  }
    #  when: {
    #    sql: ${platform_position_raw} = 'instream_video' ;;
    #    label: "InStream Video"
    #  }
    #  when: {
    #    sql: ${platform_position_raw} = 'messenger_inbox' ;;
    #    label: "Messenger Home"
    #  }
    #  else: "Other"
    # }
  }

  dimension: publisher_platform_raw {
    hidden: yes
    type: string
    sql: ${TABLE}.publisher_platform ;;
  }

  dimension: publisher_platform {
    type: string
    label: "Platform"
    sql: ${publisher_platform_raw} ;;
  }
}

view: ad_impressions_platform_and_device_fb_adapter {
  extends: [insights_base, facebook_ads_config, platform_and_device_base_fb_adapter]
  sql_table_name:
  (
    SELECT facebook_ads_ads_insights_platform_and_device.*
    FROM {{ facebook_ads_schema._sql }}.facebook_ads_insights_platform_and_device_{{ facebook_account_id._sql }} AS facebook_ads_ads_insights_platform_and_device
    INNER JOIN (
      SELECT
          MAX(_sdc_sequence) AS seq
          , ad_id
          , adset_id
          , campaign_id
          , date_start
          , publisher_platform
          , platform_position
          , impression_device
      FROM {{ facebook_ads_schema._sql }}.facebook_ads_insights_platform_and_device_{{ facebook_account_id._sql }}
      GROUP BY ad_id, adset_id, campaign_id, date_start, publisher_platform, platform_position, impression_device
    ) AS max_ads_insights_platform_and_device
    ON facebook_ads_ads_insights_platform_and_device.ad_id = max_ads_insights_platform_and_device.ad_id
    AND facebook_ads_ads_insights_platform_and_device.adset_id = max_ads_insights_platform_and_device.adset_id
    AND facebook_ads_ads_insights_platform_and_device.campaign_id = max_ads_insights_platform_and_device.campaign_id
    AND facebook_ads_ads_insights_platform_and_device.date_start = max_ads_insights_platform_and_device.date_start
    AND facebook_ads_ads_insights_platform_and_device.publisher_platform = max_ads_insights_platform_and_device.publisher_platform
    AND facebook_ads_ads_insights_platform_and_device.platform_position = max_ads_insights_platform_and_device.platform_position
    AND facebook_ads_ads_insights_platform_and_device.impression_device = max_ads_insights_platform_and_device.impression_device
    AND facebook_ads_ads_insights_platform_and_device._sdc_sequence = max_ads_insights_platform_and_device.seq
  ) ;;
}

view: ads_insights_platform_and_device__actions {
  extends: [ads_insights__actions, platform_and_device_base_fb_adapter]
  derived_table: {
    sql:
      SELECT actions.*
      FROM {{ actions.facebook_ads_schema._sql }}."facebook_ads_insights_platform_and_device_{{ actions.facebook_account_id._sql }}__actions" as actions
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
        , _sdc_source_key_publisher_platform
        , _sdc_source_key_platform_position
        , _sdc_source_key_impression_device
        FROM {{ actions.facebook_ads_schema._sql }}."facebook_ads_insights_platform_and_device_{{ actions.facebook_account_id._sql }}__actions"
        GROUP BY ad_id, adset_id, campaign_id, date_start, action_type, action_target_id, action_destination, _sdc_source_key_publisher_platform, _sdc_source_key_platform_position, _sdc_source_key_impression_device
      ) AS max_ads_actions
      ON actions._sdc_source_key_ad_id = max_ads_actions.ad_id
      AND actions._sdc_source_key_adset_id = max_ads_actions.adset_id
      AND actions._sdc_source_key_campaign_id = max_ads_actions.campaign_id
      AND actions._sdc_source_key_date_start = max_ads_actions.date_start
      AND actions._sdc_sequence = max_ads_actions.seq
      AND actions.action_type = max_ads_actions.action_type
      AND actions.action_target_id = max_ads_actions.action_target_id
      AND actions.action_destination = max_ads_actions.action_destination
      AND actions._sdc_source_key_publisher_platform = max_ads_actions._sdc_source_key_publisher_platform
      AND actions._sdc_source_key_platform_position = max_ads_actions._sdc_source_key_platform_position
      AND actions._sdc_source_key_impression_device = max_ads_actions._sdc_source_key_impression_device
      ;;
  }
  dimension: impression_device {
    sql: ${TABLE}._sdc_source_key_impression_device ;;
  }

  dimension: platform_platform_raw {
    sql: ${TABLE}._sdc_source_key_publisher_platform ;;
  }

  dimension: platform_position_raw {
    sql: ${TABLE}._sdc_source_key_platform_position ;;
  }

}
