' Nodal System Prototype, the first brick to create your own system :)
' By Creepy Cat (C) 2025/2026 (https://github.com/BlackCreepyCat)

SuperStrict

' Import necessary modules for 2D graphics, input polling, and linked lists
Import BRL.Max2D
Import BRL.PolledInput
Import BRL.LinkedList

' Set up the graphics window (1200x700 pixels, windowed mode)
Graphics 1200, 700, 0

' Global lists to store all nodes and connections in the graph
Global nodes:TList = New TList
Global links:TList = New TList

' Variables for node dragging
Global selectedNode:TNode = Null          ' Currently dragged node
Global dragOffsetX:Float, dragOffsetY:Float ' Offset from mouse to node origin when dragging

' Variables for link creation
Global creatingLink:TPort = Null          ' Port from which a new link is being dragged
Global potentialTarget:TPort = Null       ' Potential target port when dragging a link

' === Panning (view scrolling) variables ===
' These allow infinite panning of the workspace using the middle mouse button
Global viewOffsetX:Float = 0              ' Horizontal offset of the view
Global viewOffsetY:Float = 0              ' Vertical offset of the view
Global panning:Int = 0                    ' Flag: is panning active?
Global panStartX:Int, panStartY:Int       ' Mouse position when panning started

' === Test Nodes: Number nodes (constant values) ===
' Four number nodes with fixed values
Local num1:TNode = New TNode
num1.x = 50; num1.y = 100
num1.title = "Number"
num1.nodeKind = "Variable"
num1.value = 5.0
num1.AddOutput("Value", num1.width, num1.height/2)
nodes.AddLast(num1)

Local num2:TNode = New TNode
num2.x = 50; num2.y = 200
num2.title = "Number"
num2.nodeKind = "Variable"
num2.value = 3.0
num2.AddOutput("Value", num2.width, num2.height/2)
nodes.AddLast(num2)

Local num3:TNode = New TNode
num3.x = 50; num3.y = 350
num3.title = "Number"
num3.nodeKind = "Variable"
num3.value = 10.0
num3.AddOutput("Value", num3.width, num3.height/2)
nodes.AddLast(num3)

Local num4:TNode = New TNode
num4.x = 50; num4.y = 450
num4.title = "Number"
num4.nodeKind = "Variable"
num4.value = 7.0
num4.AddOutput("Value", num4.width, num4.height/2)
nodes.AddLast(num4)

' === Two Add nodes (perform addition) ===
Local add1:TNode = New TNode
add1.x = 300; add1.y = 120
add1.title = "Add 1"
add1.nodeKind = "Add"
add1.AddInput("A", 0, 40)
add1.AddInput("B", 0, 80)
add1.AddOutput("Result", add1.width, 60)
nodes. AddLast(add1)

Local add2:TNode = New TNode
add2.x = 300; add2.y = 370
add2.title = "Add 2"
add2.nodeKind = "Add"
add2.AddInput("A", 0, 40)
add2.AddInput("B", 0, 80)
add2.AddOutput("Result", add2.width, 60)
nodes.AddLast(add2)

' === Combine node - sums all incoming values ===
Local combineNode:TNode = New TNode
combineNode.x = 600; combineNode.y = 200
combineNode.title = "Combine"
combineNode.nodeKind = "Combine"
combineNode.width = 160
combineNode.height = 120
combineNode.AddInput("In1", 0, 40)
combineNode.AddInput("In2", 0, 80)
combineNode.AddOutput("Out", combineNode.width, combineNode.height/2)
nodes.AddLast(combineNode)

' === Final Result node - prints the total to console ===
Local resultNode:TNode = New TNode
resultNode.x = 900; resultNode.y = 250
resultNode.title = "Final Result"
resultNode.nodeKind = "Print"
resultNode.AddInput("In", 0, resultNode.height/2)
nodes.AddLast(resultNode)

' === Manual connections between nodes ===
' Connect Number nodes to Add nodes
Local l1:TLink = New TLink
l1.fromPort = TPort(num1.outputs.First())
l1.toPort = TPort(add1.inputs.First())
TPort(add1.inputs.First()).link = l1
links.AddLast(l1)

Local l2:TLink = New TLink
l2.fromPort = TPort(num2.outputs.First())
l2.toPort = TPort(add1.inputs.Last())
TPort(add1.inputs.Last()).link = l2
links.AddLast(l2)

Local l3:TLink = New TLink
l3.fromPort = TPort(num3.outputs.First())
l3.toPort = TPort(add2.inputs.First())
TPort(add2.inputs.First()).link = l3
links.AddLast(l3)

Local l4:TLink = New TLink
l4.fromPort = TPort(num4.outputs.First())
l4.toPort = TPort(add2.inputs.Last())
TPort(add2.inputs.Last()).link = l4
links.AddLast(l4)

' Connect Add nodes to Combine
Local l5:TLink = New TLink
l5.fromPort = TPort(add1.outputs.First())
l5.toPort = TPort(combineNode.inputs.First())
TPort(combineNode.inputs.First()).link = l5
links.AddLast(l5)

Local l6:TLink = New TLink
l6.fromPort = TPort(add2.outputs.First())
l6.toPort = TPort(combineNode.inputs.Last())
TPort(combineNode.inputs.Last()).link = l6
links.AddLast(l6)

' Connect Combine to Result
Local l7:TLink = New TLink
l7.fromPort = TPort(combineNode.outputs.First())
l7.toPort = TPort(resultNode.inputs.First())
TPort(resultNode.inputs.First()).link = l7
links.AddLast(l7)

' === Main game loop ===
While Not KeyHit(KEY_ESCAPE)
    Cls
    
    HandleInput()  ' Process mouse and keyboard input
    
    ' Apply view offset for panning
    SetOrigin(viewOffsetX, viewOffsetY)
    
    DrawNodes()    ' Draw all nodes
    DrawLinks()    ' Draw all connections and temporary link
    
    ' Reset origin for HUD elements
    SetOrigin(0, 0)
    
    ' Display current pan offset and instructions
    SetColor 255, 255, 255
    DrawText "Pan: " + viewOffsetX + ", " + viewOffsetY + "  (Hold middle mouse button to pan)", 10, 10
    
    Flip
Wend

' === TYPE DEFINITIONS ===

' Port on a node (input or output)
Type TPort
    Field owner:TNode             ' Parent node
    Field name:String             ' Display name (e.g., "Value", "A")
    Field isInput:Int             ' 1 = input port, 0 = output port
    Field relX:Float, relY:Float  ' Position relative to node top-left
    Field link:TLink = Null       ' Connected link (for inputs only)
End Type

' Main node type
Type TNode
    Field x:Float, y:Float                    ' Position in world space
    Field width:Float = 140, height:Float = 100 ' Size of the node
    Field inputs:TList = New TList            ' List of input ports
    Field outputs:TList = New TList           ' List of output ports
    Field title:String = "Untitled"           ' Title displayed on node
    Field nodeKind:String = "Generic"         ' Type of node (determines behavior and color)
    Field value:Float = 0.0                   ' Stored value (used by Variable, Add, Combine, etc.)
    
    ' Add an input port
    Method AddInput(name:String, relX:Float, relY:Float)
        Local port:TPort = New TPort
        port.owner = Self
        port.name = name
        port.isInput = 1
        port.relX = relX
        port.relY = relY
        inputs.AddLast(port)
    End Method
    
    ' Add an output port
    Method AddOutput(name:String, relX:Float, relY:Float)
        Local port:TPort = New TPort
        port.owner = Self
        port.name = name
        port.isInput = 0
        port.relX = relX
        port.relY = relY
        outputs.AddLast(port)
    End Method
    
    ' Check if a screen point is inside the node (accounting for view offset)
    Method HitTest:Int(screenX:Float, screenY:Float)
        Local worldX:Float = screenX - viewOffsetX
        Local worldY:Float = screenY - viewOffsetY
        Return (worldX >= x And worldX <= x + width And worldY >= y And worldY <= y + height)
    End Method
    
    ' Find which port (if any) is under the given screen coordinates
    Method GetPortAt:TPort(screenX:Float, screenY:Float)
        Local worldX:Float = screenX - viewOffsetX
        Local worldY:Float = screenY - viewOffsetY
        
        For Local port:TPort = EachIn inputs
            Local px:Float = x + port.relX
            Local py:Float = y + port.relY
            If (worldX - px)*(worldX - px) + (worldY - py)*(worldY - py) < 64 Then Return port
        Next
        For Local port:TPort = EachIn outputs
            Local px:Float = x + port.relX
            Local py:Float = y + port.relY
            If (worldX - px)*(worldX - px) + (worldY - py)*(worldY - py) < 64 Then Return port
        Next
        Return Null
    End Method
    
    ' Evaluate the node's logic (called when pressing 'E')
    Method Evaluate()
        Select nodeKind
            Case "Variable", "Number"
                ' Value is already set in node.value (constant)
                
            Case "Add"
                Local a:Float = 0, b:Float = 0
                If inputs.Count() >= 1 And TPort(inputs.First()).link
                    a = TPort(inputs.First()).link.fromPort.owner.value
                EndIf
                If inputs.Count() >= 2
                    Local second:TPort = TPort(inputs.Last())
                    If second.link Then b = second.link.fromPort.owner.value
                EndIf
                value = a + b  ' Store result in this node
                
            Case "Combine"
                Print "=== COMBINE NODE ==="
                Local i:Int = 1
                value = 0.0
                For Local port:TPort = EachIn inputs
                    If port.link
                        Local val:Float = port.link.fromPort.owner.value
                        Print "Input " + i + ": " + val
                        value :+ val  ' Accumulate all inputs
                        i :+ 1
                    EndIf
                Next
                Print "Total combined = " + value
                Print "===================="
                
            Case "Print", "Result"
                If inputs.Count() > 0 And TPort(inputs.First()).link
                    Local finalVal:Float = TPort(inputs.First()).link.fromPort.owner.value
                    Print "=== FINAL RESULT ==="
                    Print "Total sum = " + finalVal
                    Print "==================="
                EndIf
        End Select
    End Method
End Type

' Connection between two ports
Type TLink
    Field fromPort:TPort  ' Source port (output)
    Field toPort:TPort    ' Destination port (input)
End Type

' Evaluate the entire graph (called with 'E' key)
Function EvaluateGraph()
    Print "Graph evaluation started..."
    For Local node:TNode = EachIn nodes
        node.Evaluate()
    Next
End Function

' Draw a cubic Bézier curve between two points
Function DrawBezierLink(x1:Float, y1:Float, x2:Float, y2:Float, valid:Int = 1)
    If valid
        SetColor 100, 180, 255  ' Blue for valid connections
    Else
        SetColor 255, 100, 100  ' Red for invalid
    EndIf
    SetLineWidth 3
    
    Local dist:Float = Abs(x2 - x1)
    Local ctrlOffset:Float = Max(dist * 0.5, 60)
    
    Local cx1:Float = x1 + ctrlOffset
    Local cy1:Float = y1
    Local cx2:Float = x2 - ctrlOffset
    Local cy2:Float = y2
    
    Local segments:Int = 32
    Local prevX:Float = x1, prevY:Float = y1
    
    For Local i:Int = 1 To segments
        Local t:Float = Float(i) / segments
        Local invT:Float = 1.0 - t
        Local x:Float = invT^3 * x1 + 3*invT^2*t * cx1 + 3*invT*t^2 * cx2 + t^3 * x2
        Local y:Float = invT^3 * y1 + 3*invT^2*t * cy1 + 3*invT*t^2 * cy2 + t^3 * y2
        DrawLine prevX, prevY, x, y
        prevX = x; prevY = y
    Next
    SetLineWidth 1
End Function

' Draw all nodes with appropriate colors and labels
Function DrawNodes()
    For Local node:TNode = EachIn nodes
        ' Set background color based on node type
        Select node.nodeKind
            Case "Add", "Subtract", "Multiply", "Divide"
                SetColor 50, 70, 110      ' Blue for math operators
            Case "Variable", "Constant", "Number"
                SetColor 50, 90, 60       ' Green for constants
            Case "Print", "Log", "Result"
                SetColor 90, 50, 90       ' Purple for output
            Case "Combine"
                SetColor 100, 70, 50      ' Orange-brown for combiner
            Default
                SetColor 50, 50, 60       ' Default gray
        End Select
        DrawRect node.x, node.y, node.width, node.height
        
        ' Draw border
        SetColor 200, 200, 200
        DrawLine node.x, node.y, node.x + node.width, node.y
        DrawLine node.x, node.y, node.x, node.y + node.height
        DrawLine node.x + node.width, node.y, node.x + node.width, node.y + node.height
        DrawLine node.x, node.y + node.height, node.x + node.width, node.y + node.height
        
        ' Draw title
        SetColor 230, 230, 255
        DrawText node.title, node.x + 10, node.y + 8
        
        ' Title separator line
        SetColor 100, 100, 150
        DrawLine node.x + 5, node.y + 25, node.x + node.width - 5, node.y + 25
        
        ' Draw input ports (left side)
        For Local port:TPort = EachIn node.inputs
            If port.link Then SetColor 0, 255, 100 Else SetColor 0, 200, 0
            DrawOval node.x + port.relX - 7, node.y + port.relY - 7, 14, 14
            SetColor 0, 80, 0
            DrawOval node.x + port.relX - 4, node.y + port.relY - 4, 8, 8
            SetColor 255, 255, 255
            DrawText port.name, node.x + port.relX + 12, node.y + port.relY - 8
        Next
        
        ' Draw output ports (right side)
        For Local port:TPort = EachIn node.outputs
            SetColor 255, 150, 50
            DrawOval node.x + port.relX - 7, node.y + port.relY - 7, 14, 14
            SetColor 180, 80, 0
            DrawOval node.x + port.relX - 4, node.y + port.relY - 4, 8, 8
            SetColor 255, 255, 255
            DrawText port.name, node.x + port.relX - 14 - TextWidth(port.name), node.y + port.relY - 8
        Next
    Next
End Function

' Draw all links and the temporary link being created
Function DrawLinks()
    ' Draw existing links
    For Local link:TLink = EachIn links
        Local fx:Float = link.fromPort.owner.x + link.fromPort.relX
        Local fy:Float = link.fromPort.owner.y + link.fromPort.relY
        Local tx:Float = link.toPort.owner.x + link.toPort.relX
        Local ty:Float = link.toPort.owner.y + link.toPort.relY
        DrawBezierLink(fx, fy, tx, ty, 1)
    Next
    
    ' Draw temporary link while creating a connection
    If creatingLink
        Local mouseWorldX:Float = MouseX() - viewOffsetX
        Local mouseWorldY:Float = MouseY() - viewOffsetY
        
        Local startX:Float = creatingLink.owner.x + creatingLink.relX
        Local startY:Float = creatingLink.owner.y + creatingLink.relY
        Local valid:Int = (potentialTarget <> Null And potentialTarget.isInput <> creatingLink.isInput And potentialTarget.link = Null)
        
        If creatingLink.isInput = 0  ' Starting from output
            DrawBezierLink(startX, startY, mouseWorldX, mouseWorldY, valid)
        Else  ' Starting from input (reconnecting)
            DrawBezierLink(mouseWorldX, mouseWorldY, startX, startY, valid)
        EndIf
    EndIf
End Function

' Handle all user input (mouse + keyboard)
Function HandleInput()
    Local screenX:Int = MouseX()
    Local screenY:Int = MouseY()
    
    ' === Middle mouse button panning ===
    If MouseHit(3)  ' Middle mouse button clicked
        panning = 1
        panStartX = screenX
        panStartY = screenY
    EndIf
    
    If MouseDown(3) And panning
        viewOffsetX :+ screenX - panStartX
        viewOffsetY :+ screenY - panStartY
        panStartX = screenX
        panStartY = screenY
        Return  ' Panning takes priority
    Else
        panning = 0
    EndIf
    
    potentialTarget = Null
    
    ' Detect potential connection target while dragging a link
    If creatingLink
        For Local node:TNode = EachIn nodes
            Local port:TPort = node.GetPortAt(screenX, screenY)
            If port And port.owner <> creatingLink.owner
                If creatingLink.isInput = 0 And port.isInput = 1 And port.link = Null
                    potentialTarget = port
                    Exit
                ElseIf creatingLink.isInput = 1 And port.isInput = 0
                    potentialTarget = port
                    Exit
                EndIf
            EndIf
        Next
    EndIf
    
    ' Left mouse button clicked
    If MouseHit(1)
        Local clickedPort:TPort = Null
        For Local node:TNode = EachIn nodes
            clickedPort = node.GetPortAt(screenX, screenY)
            If clickedPort Exit
        Next
        
        ' Start creating a link from a port
        If clickedPort
            creatingLink = clickedPort
            If clickedPort.isInput = 1 And clickedPort.link
                links.Remove(clickedPort.link)
                clickedPort.link = Null
            EndIf
            Return
        EndIf
        
        ' Start dragging a node
        For Local node:TNode = EachIn nodes
            If node.HitTest(screenX, screenY)
                selectedNode = node
                dragOffsetX = screenX - viewOffsetX - node.x
                dragOffsetY = screenY - viewOffsetY - node.y
                Return
            EndIf
        Next
    EndIf
    
    ' Drag selected node
    If MouseDown(1) And selectedNode
        selectedNode.x = screenX - viewOffsetX - dragOffsetX
        selectedNode.y = screenY - viewOffsetY - dragOffsetY
    Else
        selectedNode = Null
    EndIf
    
    ' Release mouse button - finalize link creation
    If Not MouseDown(1) And creatingLink
        If potentialTarget
            Local outputPort:TPort
            Local inputPort:TPort
            If creatingLink.isInput = 0
                outputPort = creatingLink
                inputPort = potentialTarget
            Else
                outputPort = potentialTarget
                inputPort = creatingLink
            EndIf
            Local link:TLink = New TLink
            link.fromPort = outputPort
            link.toPort = inputPort
            inputPort.link = link
            links.AddLast(link)
        EndIf
        creatingLink = Null
        potentialTarget = Null
    EndIf
    
    ' Right click - delete link (by clicking on connected input port)
    If MouseHit(2)
        For Local node:TNode = EachIn nodes
            Local port:TPort = node.GetPortAt(screenX, screenY)
            If port And port.isInput = 1 And port.link
                links.Remove(port.link)
                port.link = Null
                Return
            EndIf
        Next
    EndIf
    
    ' Press 'E' to evaluate the entire graph
    If KeyHit(KEY_E)
        EvaluateGraph()
    EndIf
End Function
