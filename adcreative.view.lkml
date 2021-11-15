include: "ad.view"
include: "adset.view"

explore: adcreative_nested_joins_base {
  extension: required

  join: adcreative_object_story_spec {
    view_label: "Adcreative: Object Story Spec"
    sql_on: ${adcreative.id} = ${adcreative_object_story_spec.id};;
    relationship: one_to_one
  }
}

explore: adcreative_fb_adapter {
  persist_with: facebook_ads_etl_datagroup
  view_name: adcreative
  from: adcreative_fb_adapter
  extends: [adcreative_nested_joins_base]
  hidden: yes

  join: ad {
    from: fb_ad
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

view: adcreative_fb_adapter {
  extends: [stitch_base, facebook_ads_config]
  # sql_table_name: {{ facebook_ads_schema._sql }}.facebook_adcreative_{{ facebook_account_id._sql }} ;;
  sql_table_name: (
    SELECT adcreative.*
    FROM {{ facebook_ads_schema._sql }}.facebook_adcreative_{{ facebook_account_id._sql }} AS adcreative
    INNER JOIN (
      SELECT
        MAX(_sdc_sequence) AS seq
        , id
      FROM {{ facebook_ads_schema._sql }}.facebook_adcreative_{{ facebook_account_id._sql }}
      GROUP BY id
      ) AS max_adcreative
    ON adcreative.id = max_adcreative.id
    AND adcreative._sdc_sequence = max_adcreative.seq
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

  dimension: body {
    type: string
  }

  dimension: call_to_action_type {
    type: string
  }

  dimension: effective_instagram_story_id {
    hidden: yes
    type: string
  }

  dimension: effective_object_story_id {
    hidden: yes
    type: string
  }

  dimension: image_hash {
    hidden: yes
    type: string
  }

  dimension: image_url {
    hidden: yes
    type: string
    html: "<img src='{{value}}' />" ;;
  }

  dimension: instagram_actor_id {
    type: string
    hidden: yes
  }

  dimension: instagram_permalink_url {
    hidden: yes
    type: string
  }

  dimension: name {
    type: string
  }

  dimension: object_story_id {
    hidden: yes
    type: string
  }

  dimension: object_story_spec {
    hidden: yes
  }

  dimension: object_type {
    type: string
  }

  dimension: status {
    type: string
    hidden: yes
  }

  dimension: status_active {
    type: yesno
    sql: ${status} = 'ACTIVE' ;;
  }

  dimension: thumbnail_url {
    type: string
    html: "<img src='{{value}}' />" ;;
  }

  dimension: title {
    type: string
  }

  dimension: video_id {
    type: string
    hidden: yes
  }
}

view: adcreative_object_story_spec {
  extends: [stitch_base, facebook_ads_config]
  derived_table: {
    sql:
        SELECT
          adcreative.id as id,
          adcreative._sdc_batched_at,
          adcreative._sdc_received_at,
          adcreative._sdc_sequence,
          adcreative._sdc_table_version,
          adcreative.object_story_spec__instagram_actor_id as instagram_actor_id,
          adcreative.object_story_spec__page_id as page_id,
          adcreative.object_story_spec__video_data__call_to_action__type as video_data_call_to_action_type,
          adcreative.object_story_spec__link_data__call_to_action__type as link_data_call_to_action_type,
          adcreative.object_story_spec__video_data__call_to_action__value__link as video_data_call_to_action_link,
          adcreative.object_story_spec__video_data__call_to_action__value__link_caption as video_data_call_to_action_link_caption,
          adcreative.object_story_spec__video_data__image_hash as video_data__image_hash,
          adcreative.object_story_spec__video_data__image_url as video_data__image_url,
          adcreative.object_story_spec__video_data__video_id as video_data__video_id,
          adcreative.object_story_spec__video_data__description as video_data__description,
          adcreative.object_story_spec__link_data__name as link_data_name,
          adcreative.object_story_spec__link_data__message as link_data_message,
          adcreative.object_story_spec__link_data__link as link_data_link,
          adcreative.object_story_spec__link_data__image_hash as link_data_image_hash,
          adcreative.object_story_spec__link_data__description as link_data_description,
          adcreative.object_story_spec__link_data__caption as link_data_caption
          adcreative.object_story_spec__link_data__picture as link_data_picture
          adcreative.object_story_spec__link_data__attachment_style as link_data_attachment_style

        FROM
        {{ facebook_ads_schema._sql }}.facebook_adcreative_{{ facebook_account_id._sql }} as adcreative
        ;;
  }

  dimension: instagram_actor_id {
    hidden: yes
    type: string
  }


  dimension: id {
    hidden: yes
    type: string
  }

  dimension: page_id {
    hidden: yes
    type: string
  }

  dimension: video_data_call_to_action_type {
    hidden: yes
    type: string
  }


  dimension: link_data_call_to_action_type {
    hidden: yes
    type: string
  }

  dimension: video_data_call_to_action_link {
    hidden: yes
    type: string
  }

  dimension: video_data_call_to_action_link_caption {
    hidden: yes
    type: string
  }

  dimension: video_data_call_to_action_link_format {
    hidden: yes
    type: string
    sql: 'NA'::text ;;
  }

  dimension: video_data__image_hash {
    hidden: yes
    type: string
  }

  dimension: video_data__image_url {
    hidden: yes
    type: string
  }

  dimension: video_data__video_id {
    hidden: yes
    type: string
  }

  dimension: video_data__description {
    hidden: yes
    type: string
  }

  dimension: video_data__call_to_action_lead_gen_form_id {
    hidden: yes
    type: string
    sql: 'NA'::text ;;
  }

  dimension: video_data_message {
    hidden: yes
    type: string
    sql: 'NA'::text ;;
  }

  dimension: video_data_title {
    hidden: yes
    type: string
    sql: 'NA'::text ;;
  }

  dimension: link_data_name {
    hidden: yes
    type: string
  }

  dimension: link_data_message {
    hidden: yes
    type: string
  }

  dimension: link_data_link {
    hidden: yes
    type: string
  }

  dimension: link_data_image_hash {
    hidden: yes
    type: string
  }

  dimension: link_data_description {
    hidden: yes
    type: string
  }

  dimension: link_data_caption {
    hidden: yes
    type: string
  }

  dimension: link_data_picture {
    hidden: yes
    type: string
  }

  dimension: link_data_attachment_style {
    hidden: yes
    type: string
  }


}
