class Node
    
    constructor: (@_name, @_parent, @_id, @_level, @_tree) ->
        @_children_amount = 0
        @_children = []
    
    addChild: (id) ->
        @_children_amount++
        @_children.push id
    
    removeChild: (id) ->
        @_children_amount--
        childPos = @_children.indexOf(id)
        if parent != 0 and childPos > -1
            @_children.splice(childPos, 1)
        
    draw: ->
        
        dom_parent = $("#node-"  + @_parent).find("ul:first")
        
        if @_parent == 0
            dom_parent = @_tree.getStartingElement()
        
        
        dom_parent.append(
            $("<li>")
                .text(@_name)
                .attr("id", "node-" + @_id)
                .append(
                    $("<button>")
                        .text("X")
                        .click => 
                                getTree().eraseNode(@_id)
                                false
                )
                .append(
                    $("<button>")
                        .text("Change Name")
                        .data('node', @_id)
                        .click ->
                            if $(@).text() == "Change Name"
                              $(@).siblings('input').show()
                              $(@).text("Save")
                            else
                              $(@).siblings('input').hide()  
                              $(@).text("Change Name")
                              changeName($(@).data('node'), $(@).siblings('input').val())
                )
                .append(
                    $("<input>")
                        .attr("type", "text")
                        .hide()
                )
        );
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
        
    erase: ->
        
        for i in [@_children.length - 1..0] by -1 
            child_node = @_tree.eraseNode @_children[i]
        
        parent_node = @_tree.getNode(@_parent)
        if parent_node
            parent_node.removeChild(@_id)
        $("#node-" + @_id).remove()
        this
        
    setName: (newName) ->
        @_name = newName
        
class Tree
    
    constructor: (@_starting_element_id) ->
        @_was_drawn = false
        @_node_amount = 0
        @_nodes = {}
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
        
    getNode: (nodeId) ->
        if nodeId of @_nodes
            @_nodes[nodeId]
        else
            undefined
    
    getStartingElement: ->
        $("#" + @_starting_element_id)
    
    changeNodeName: (nodeId, newName) ->
        if nodeId of @_nodes
            @_nodes[nodeId].setName(newName)
            @draw()
    
    eraseNode: (nodeId) ->
        if nodeId of @_nodes
            @_nodes[nodeId].erase()
            delete @_nodes[nodeId]
            if nodeId in @_my_nodes
                @_my_nodes.splice(@_my_nodes.indexOf(nodeId), 1)
        this
    
    erase: ->
        for i in [@_my_nodes.length - 1..0] by -1
            @eraseNode(@_my_nodes[i])
        undefined
    
tree = undefined
  
createTree = (parentElement) ->
    if tree
        tree.erase()
    tree = new Tree(parentElement)
    
getTree = ->
    return tree
    
changeName = (id, name) ->
    if tree
        tree.changeNodeName(id, name)

window.createTree = createTree
window.getTree = getTree
window.changeName = changeName