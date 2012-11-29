require 'test/unit'
require 'cascading'

class TC_Cascade < Test::Unit::TestCase
  def test_cascade
    f1, a1, a2, f2, a3, a4 = [nil] * 6
    cascade = cascade 'cascade' do
      f1 = flow 'flow1' do
        a1 = assembly 'assembly1' do
        end

        a2 = assembly 'assembly2' do
        end
      end

      f2 = flow 'flow2' do
        a3 = assembly 'assembly3' do
        end

        a4 = assembly 'assembly4' do
        end
      end
    end

    assert_equal 2, cascade.children.size
    assert_equal f1, cascade.children['flow1']
    assert_equal f1, cascade.find_child('flow1')
    assert_equal f2, cascade.last_child
    assert_equal f2, cascade.find_child('flow2')
    assert_equal ['flow1', 'flow2'], cascade.child_names

    assert_equal cascade, f1.parent
    assert_equal cascade, f2.parent
    assert_equal f1, a1.parent
    assert_equal f1, a2.parent
    assert_equal f2, a3.parent
    assert_equal f2, a4.parent

    assert_nil cascade.parent
    assert_equal cascade, cascade.root
    assert_equal cascade, cascade.last_child.last_child.root

    assert_equal 'cascade', cascade.qualified_name
    assert_equal 'cascade.flow2', cascade.last_child.qualified_name
    assert_equal 'cascade.flow2.assembly4', cascade.last_child.last_child.qualified_name
  end

  def test_default_properties
    f1, f2 = nil, nil
    cascade = cascade 'cascade' do
      f1 = flow 'flow1' do
      end

      f2 = flow 'flow2' do
      end
    end

    assert_equal({}, cascade.properties)
    assert_equal({}, f1.properties)
    assert_equal({}, f2.properties)
  end

  def test_set_properties
    # Simulate the global properties set by jading
    $jobconf_properties = {
      'external_no_overwrite' => 'external_no_overwrite',
      'external_overwrite' => 'external_overwrite',
    }

    f1, f2 = nil, nil
    cascade = cascade 'cascade' do
      properties['external_overwrite'] = 'overwritten'
      properties['internal_no_overwrite'] = 'internal_no_overwrite'
      properties['internal_overwrite'] = 'internal_overwrite'

      f1 = flow 'flow1' do
        properties['external_overwrite'] = 'overwritten_flow1'
        properties['internal_overwrite'] = 'overwritten_flow1'
      end

      f2 = flow 'flow2' do
        properties['external_overwrite'] = 'overwritten_flow2'
        properties['internal_overwrite'] = 'overwritten_flow2'
      end
    end

    assert_equal({
      'external_no_overwrite' => 'external_no_overwrite',
      'external_overwrite' => 'overwritten',
      'internal_no_overwrite' => 'internal_no_overwrite',
      'internal_overwrite' => 'internal_overwrite',
    }, cascade.properties)

    assert_equal({
      'external_no_overwrite' => 'external_no_overwrite',
      'external_overwrite' => 'overwritten_flow1',
      'internal_no_overwrite' => 'internal_no_overwrite',
      'internal_overwrite' => 'overwritten_flow1',
    }, f1.properties)

    assert_equal({
      'external_no_overwrite' => 'external_no_overwrite',
      'external_overwrite' => 'overwritten_flow2',
      'internal_no_overwrite' => 'internal_no_overwrite',
      'internal_overwrite' => 'overwritten_flow2',
    }, f2.properties)
  end

  def test_ambiguous_flow_names
    ex = assert_raise AmbiguousNodeNameException do
      f1, a1, a2, f2, a3, a4 = [nil] * 6
      cascade = cascade 'cascade' do
        f1 = flow 'f' do
          a1 = assembly 'assembly1' do
          end

          a2 = assembly 'assembly2' do
          end
        end

        f2 = flow 'f' do
          a3 = assembly 'assembly3' do
          end

          a4 = assembly 'assembly4' do
          end
        end
      end
    end
    assert_equal "Attempted to add 'cascade.f', but node named 'f' already exists", ex.message
  end

  def test_ambiguous_assembly_names
    # You _can_ define ambiguously named assemblies between flows
    f1, a1, a2, f2, a3, a4 = [nil] * 6
    cascade = cascade 'cascade' do
      f1 = flow 'flow1' do
        a1 = assembly 'a' do
        end

        a2 = assembly 'assembly2' do
        end
      end

      f2 = flow 'flow2' do
        a3 = assembly 'a' do
        end

        a4 = assembly 'assembly4' do
        end
      end
    end

    # You _cannot_ look them up using find_child
    ex = assert_raise AmbiguousNodeNameException do
      cascade.find_child('a')
    end
    assert_equal "Ambiguous lookup of child by name 'a'; found 'cascade.flow1.a', 'cascade.flow2.a'", ex.message

    # NOTE: Looking up flows this way is not a very common practice, so this is
    # unlikely to cause issues
  end

  def test_smoke_test_describe
    cascade 'smoke' do
      puts "Describe at cascade start: '#{describe}'"

      flow 'smoke' do
        source 'input', tap('test/data/data1.txt')
        assembly 'input' do
          group_by 'line' do
            count
            sum 'offset', :type => :long
          end
        end
        sink 'input', tap('output/test_smoke_test_debug_scope')
      end

      puts "Describe at cascade end: '#{describe}'"
    end
  end
end
