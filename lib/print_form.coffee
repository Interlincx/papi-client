
module.exports = (list, class_name, number_of_items=10) ->
  $main = $('<div/>').addClass class_name+'_form'

  console.log 'LISET', list
  field_number = 0
  form_number = 0
  $current = false
  for name, values of list
    if field_number == number_of_items or $current == false
      form_number++
      field_number = 0
      if $current != false
        $main.append $current
      $current = $('<div/>').addClass 'form'+form_number+' form_parts'

    if values.client_editable != false
      field_number++
    attr_settings =
      data_id: values.id_find
      input_type: values.type

    values.class_name = class_name

    rendered_setting = this.formify(attr_settings, values)
    $current.append rendered_setting

  $main.append $current

  return $main
