            use Tree::Simple;
            use Data::TreeDumper;    # Provides DumpTree().

            # ---------------

            my ($root) = Tree::Simple->new( 'Root', Tree::Simple->ROOT );

            $root->generateChild('Child 1.0');
            $root->generateChild('Child 2.0');
            $root->getChild(0)->generateChild('Grandchild 1.1');

            print DumpTree($root);

            $root->DESTROY;

