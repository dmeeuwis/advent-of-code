import igraph

f = open('input', 'r')
text = f.read()
lines = text.split('\n')
lines.pop() # drop empty

vertices = set()
edges = set()

for line in lines:
    a, b = line.split(': ')
    bs = b.split()

    vertices.add(a)
    for b in bs:
        vertices.add(b)
        edges.add((a, b))

g = igraph.Graph()

for vert in vertices:
    g.add_vertex(vert)

for a, b in edges:
    g.add_edge(a, b)

cut = g.mincut()

print(len(cut.partition[0]) * len(cut.partition[1]))
