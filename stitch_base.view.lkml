view: stitch_base {
  extension: required

  dimension: _sdc_batched {
    hidden: yes
    type: date_time
  }

  dimension: _sdc_received {
    hidden: yes
    type: date_time
  }

  dimension: _sdc_sequence {
    hidden: yes
    type: number
  }

  dimension: _sdc_table_version {
    hidden: yes
    type: number
  }
}
