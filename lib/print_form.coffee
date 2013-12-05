
module.exports = (list, class_name, number_of_items=10, order=[], exclude=[]) ->
  $main = $('<div/>').addClass class_name+'_form'

  tmp = []
  if order.length > 0
    for handle in order
      tmp.push handle
    for handle, item of list
      if tmp.indexOf(handle) == -1
        tmp.push handle
  else
    for handle, item of list
      tmp.push handle

  field_number = 0
  form_number = 0
  $current = false
  for name in tmp
    if exclude.indexOf(name) > -1
      continue
    item = list[name]
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
      input_type: item.type

    item.class_name = class_name+' '+name

    rendered_setting = this.formify(attr_settings, item)
    $current.append rendered_setting

  $main.append $current

  return $main
