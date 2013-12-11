

module.exports =
  createModal: (options, callback) ->
    @options = options

    $modal = $("<div/>").attr("id", options.item_label).addClass("modal")
    $header = $("<div/>").addClass("modal-header").html '<h3>'+options.title+'</h3>'
    $typea = $("<input/>").addClass("modal_typeahead").attr("type", "search").attr("autocomplete", 'off').keydown ->
      $('.itemRow').hide()
  
    $modalBody = $("<div/>").addClass("modal-body").html "loading ..."
    $modal.append $header
    $header.append $typea
    $modal.append $modalBody
    $modal.modal "show"
  
    callback()
  
  
  populateModal: (rows, callback, params, e) ->
    @cb = callback
    @params = params

    {item_label,item_id_handle,selected_id,title, original_event} = @options
  
    $('.modal-body').empty()
  
    @c_items = []
    @c_titles = []
  
    obj = {}
    obj[item_id_handle] = ''
    obj[item_label] = '(blank)'
    rows.unshift obj
  
    $table = @rowsToTable rows,
      item_label: item_label
      item_id_handle: item_id_handle
  
    for row in rows
      title = row[item_label]
      if title != '' and title != null
        @c_items[title] = row
        @c_titles.push(title)
    console.log @c_titles
    console.log @c_items
  
    _this = @
    t_options =
      source: @c_titles
      updater: (item) ->
        console.log _this.c_items[item]
      highlighter: (item) ->
        itemid = '.'+_this.c_items[item][item_id_handle]
        $('.dropdown-menu').hide()
        $(itemid).show()
        return false
  
    console.log t_options
    $('.modal_typeahead').typeahead(t_options).keyup ->
      $('.dropdown-menu').hide()
  
    $('.modal-body').html $table
  

  rowsToTable: (rows, table_settings) ->
    $holder = $("<ul/>").addClass('nav nav-tabs nav-stacked')
    _this = @

    for row in rows
      clickData = {}
      for thing, thing_val of @options
        clickData[thing] = thing_val

      clickData.data_id = row[table_settings.item_id_handle]
      clickData.data_name = row[table_settings.item_label]
      clickData.data_row = row
      $td = $("<li/>").attr('id', row[table_settings.item_id_handle]).addClass('itemRow').addClass(row[table_settings.item_id_handle])
      $a = $("<a>#{row[table_settings.item_label]}</a>")
      $a.click(clickData, @clickItem)
      $td.append("<a>#{row[table_settings.item_label]}</a>").click clickData, (e) ->
        $('.modal').modal 'hide'
        _this.cb(e, e.data, _this.params)
      $holder.append $td

    return $holder[0]

