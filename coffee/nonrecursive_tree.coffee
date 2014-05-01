class Node
    
    constructor: (@_name, @_parent, @_id, @_tree) ->
        @_children_amount = 0
    
    addChild: (id) ->
        @_children_amount++
    
    removeChild: (id) ->
        @_children_amount--
        
    draw: ->
        dom_parent = $("#node-"  + @_parent).find("ul:first")
        
        if @_parent == 0
            dom_parent = @_tree.getStartingElement().find("ul:first")
        
        
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
        )
        $("#node-"  + @_id).append($("<ul>"))
        
        this
    
    getId: -> 
        @_id
    
    getParent: ->
        @_parent
    
    getName: ->
        @_name
            
    erase: ->
        $("#node-" + @_id).remove()
        this
        
    setName: (newName) ->
        @_name = newName
        
class Tree
    
    constructor: (@_starting_element_id) ->
        @_node_amount = 0
        @_was_drawn = false
        @_last_id = 0
        @_nodes = {}
    
    draw: ->
        $("#" + @_starting_element_id).empty()
        
        $("#" + @_starting_element_id).append(
            $("<ul>")
        )
        for childKey of @_nodes
           @_nodes[childKey].draw()

        @was_drawn = true
        this
        
    add: (parent, name) ->
        @_last_id++
        @_node_amount++
        id = @_last_id
        
        if parent != 0
            @_nodes[parent].addChild(id)
            
        @_nodes[id] = new Node(name, parent, id, this)
        
        id
        
    getNode: (nodeId) ->
        if nodeId of @_nodes
            @_nodes[nodeId]
        else
            undefined
    
    getTotalNodes:
        @_node_amount
    
    getStartingElement: ->
        $("#" + @_starting_element_id)
    
    changeNodeName: (nodeId, newName) ->
        if nodeId of @_nodes
            @_nodes[nodeId].setName(newName)
            @draw()
        this
    
    eraseNode: (nodeId) ->
        @_node_amount++
        if nodeId of @_nodes
            nodes_to_erase = [nodeId]
            values_to_look_for = [nodeId]
            while values_to_look_for.length > 0
                parentId = values_to_look_for.shift()
                for nodeKey of @_nodes
                    currentNode = @_nodes[nodeKey]
                    if currentNode.getParent() == parentId
                        nodes_to_erase.push currentNode.getId()
                        values_to_look_for.push currentNode.getId()
                
            console.log(nodes_to_erase)
            for id in nodes_to_erase
                @_nodes[id].erase()
                delete @_nodes[id]
        this
    
    erase: ->
        for i in [@_nodes.length - 1..0] by -1
            @eraseNode(@_nodes[i])
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

saveTree = (name) ->
    if tree
        if localStorage?
            localStorage[name] = tree.getJson()
        else
            alert('No localstorage supported')
        
        
loadTree = (name, location) ->
    if tree
        tree.erase()
    if localStorage?
        if (localStorage[name])
            treeNodes = JSON.parse localStorage[name]
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