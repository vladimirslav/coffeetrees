class Node
    
    constructor: (@_name, @_parent, @_id, @_level, @_tree) ->
        @_children_amount = 0
        @_children = []
    
    addChild: (id) ->
        @_children_amount++
        @_children.push id
        
    draw: ->
        
        dom_parent = $("#node-"  + @_parent).find("ul:first")
        
        if @_parent == 0
            dom_parent = @_tree.getStartingElement()
        
        
        dom_parent.append($("<li>").text(@_name).attr("id", "node-" + @_id));
        $("#node-"  + @_id).append($("<ul>"))
        
        for child in @_children
            child_node = @_tree.getNode child
            if child_node
               child_node.draw()
        this
        
    getName: ->
        @_name
    
    getLevel: ->
        @_level
    
class @Tree
    
    constructor: (@_starting_element_id) ->
        @_was_drawn = false
        @_node_amount = 0
        @_nodes = []
        @_my_nodes = []
    
    draw: ->
        if @was_drawn
            $("#" + @_starting_element_id).remove()
        
        $("body").append(
            $("<ul>").attr("id", @_starting_element_id)
        )
        
        for node in @_my_nodes
            @_nodes[node].draw()

        @was_drawn = true
        this
        
    add: (parent, name) ->
        @_node_amount++;
        id = @_node_amount
        level = 0
        
        if parent != 0
            level = @_nodes[parent].getLevel()
            @_nodes[parent].addChild(id)
            parent_node = $("#node-" + parent).find("ul:first")
        else
            @_my_nodes.push id
            
        @_nodes[id] = new Node(name, parent, id, level + 1, this)
        
        this
        
    getNode: (node_id) ->
        if node_id of @_nodes
            @_nodes[node_id]
        else
            undefined
    
    getStartingElement: ->
        return $("#" + @_starting_element_id)
