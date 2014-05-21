
module.exports = (schema, values, class_name, number_of_items=10, order=[], exclude=[]) ->
  $main = $('<div/>').addClass class_name+'_form'
  if typeof schema is 'string'
    schema = this.schemas.tables[schema].fields

  tmp = []
  if order.length > 0
    for handle in order
      tmp.push handle
    for handle, item of schema
      if tmp.indexOf(handle) == -1
        tmp.push handle
  else
    for handle, item of schema
      tmp.push handle

  field_number = 0
  form_number = 0
  $current = false
  for name in tmp
    if exclude.indexOf(name) > -1
      continue
    item = schema[name]
    if field_number == number_of_items or $current == false
      form_number++
      field_number = 0
      if $current != false
        $main.append $current
      $current = $('<div/>').addClass 'form'+form_number+' form_parts'

    if item.client_editable != false
      field_number++
    attr_settings =
      data_id: item.id_find
      data_handle: name

    current_val = ''
    if typeof values[name] != 'undefined'
      current_val = values[name]

    rendered_setting = this.formify(attr_settings, item, current_val, class_name)
    $current.append rendered_setting

  $main.append $current

  return $main
