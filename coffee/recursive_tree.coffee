class Node
    
    constructor: (@_name, @_parent, @_id, @_tree) ->
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
                                @_tree.eraseNode(@_id)
                                false
                )
                .append(
                    $("<button>")
                        .text("+")
                        .click => 
                                id = @_tree.add(@_id, "")
                                new_node = @_tree.getNode id
                                new_node.draw()
                                false
                )
                .append(
                    $("<button>")
                        .text("Edit")
                        .data('node', @_id)
                        .click ->
                            if $(@).text() == "Edit"
                              $(@).siblings('input').show()
                              $(@).text("Save")
                            else
                              $(@).siblings('input').hide()  
                              $(@).text("Edit")
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
    
    getId: -> 
        @_id
    
    getParent: ->
        @_parent
    
    getName: ->
        @_name
            
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
        @_last_id = 0
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
        @_last_id++;
        id = @_last_id
        
        if parent != 0
            @_nodes[parent].addChild(id)
        else
            @_my_nodes.push id
            
        @_nodes[id] = new Node(name, parent, id, this)
        
        id
        
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
    
    getJson: ->
        data = {}
        
        for nodeKey of @_nodes
            node = @_nodes[nodeKey]
            id = node.getId()
            
            data[id] = {name: node.getName(), parent: node.getParent()}
        
        JSON.stringify data
    
    load: (nodes) ->
        for nodeKey of nodes
            node = nodes[nodeKey]
            id = nodeKey
            
            # we know that child nodes can only be added to previously created nodes
            # no need to check if parent exist
            if node.parent != 0
                @_nodes[node.parent].addChild(id)
            else
                @_my_nodes.push id
                
            @_nodes[id] = new Node(node.name, node.parent, id, this)
            @_last_id = parseInt(nodeKey, 10) + 1
        
        this
        
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

saveTree = ->
    if tree
        if localStorage?
            localStorage["tree"] = tree.getJson()
        else
            alert('No localstorage supported')
        
        
loadTree = (location) ->
    if tree
        tree.erase()
    if localStorage?
        if (localStorage["tree"])
            treeNodes = JSON.parse localStorage["tree"]
            tree = new Tree(location)
            tree.load(treeNodes)
        else
            alert('Tree not found')
    else
        alert('No localstorage supported')
        
window.createTree = createTree
window.getTree = getTree
window.changeName = changeName
window.saveTree = saveTree
window.loadTree = loadTree