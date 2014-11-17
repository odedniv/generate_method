require 'generate_method'

describe GenerateMethod::Generator do
  subject(:instance) { klass.new }

  describe "#generate_method" do
    context "without overrider" do
      let(:parent) do
        Class.new do
          def x?(a, b)
            "parent#{a}#{b}#{yield}"
          end
        end
      end
      let(:klass) do
        Class.new(parent) do
          generate_method(:x?) { |a, b, &block| super(a, b, &block) + "-generated#{a}#{b}#{block.call}" }
          def x?(a, b)
            super + "-sub#{a}#{b}#{yield}"
          end
        end
      end

      it { should_not respond_to(:x_without_override?) }
      specify { expect(instance.x?(1, 2) { '-block' }).to eq('parent12-block-generated12-block-sub12-block') }
    end

    context "with overrider" do
      context "when supports alias" do
        let(:klass) do
          Class.new do
            def x!(a, b)
              "parent#{a}#{b}#{yield}"
            end
            generate_method(:x!, overrider: :override) { |a, b, &block| x_without_override!(a, b, &block) + "-generated#{a}#{b}#{block.call}" }
            def x!(a, b)
              super + "-sub#{a}#{b}#{yield}"
            end
          end
        end

        it { should respond_to(:x_without_override!) }
        specify { expect(instance.x!(1, 2) { '-block' }).to eq('parent12-block-generated12-block-sub12-block') }
      end

      context "when does not support alias" do
        let(:parent) do
          Class.new do
            def method_missing(method_name, *args, &block)
              method_name == :x? ? "parent#{args.join}#{yield}" : super
            end
          end
        end
        let(:klass) do
          Class.new(parent) do
            generate_method(:x?, overrider: :override) { |a, b, &block| super(a, b, &block) + "-generated#{a}#{b}#{block.call}" }
            def x?(a, b)
              super + "-sub#{a}#{b}#{yield}"
            end
          end
        end

        it { should_not respond_to(:x_without_override?) }
        specify { expect(instance.x?(1, 2) { '-block' }).to eq('parent12-block-generated12-block-sub12-block') }
      end
    end
  end

  describe "#generate_methods" do
    context "without overrider" do
      let(:parent) do
        Class.new do
          def x(a, b)
            "parentx#{a}#{b}#{yield}"
          end
          def y(a, b)
            "parenty#{a}#{b}#{yield}"
          end
        end
      end
      let(:klass) do
        Class.new(parent) do
          generate_methods do
            def x(a, b)
              super + "-generatedx#{a}#{b}#{yield}"
            end
            def y(a, b)
              super + "-generatedy#{a}#{b}#{yield}"
            end
          end
          def x(a, b)
            super + "-subx#{a}#{b}#{yield}"
          end
          def y(a, b)
            super + "-suby#{a}#{b}#{yield}"
          end
        end
      end

      it { should_not respond_to(:x_without_override) }
      it { should_not respond_to(:y_without_override) }
      specify { expect(instance.x(1, 2) { '-block' }).to eq('parentx12-block-generatedx12-block-subx12-block') }
      specify { expect(instance.y(1, 2) { '-block' }).to eq('parenty12-block-generatedy12-block-suby12-block') }
    end

    context "with overrider" do
      context "when supports alias" do
        let(:klass) do
          Class.new do
            def x!(a, b)
              "parentx#{a}#{b}#{yield}"
            end
            def y!(a, b)
              "parenty#{a}#{b}#{yield}"
            end
            generate_methods(overrider: :override) do
              def x!(a, b, &block)
                x_without_override!(a, b, &block) + "-generatedx#{a}#{b}#{yield}"
              end
              def y!(a, b, &block)
                y_without_override!(a, b, &block) + "-generatedy#{a}#{b}#{yield}"
              end
            end
            def x!(a, b)
              super + "-subx#{a}#{b}#{yield}"
            end
            def y!(a, b)
              super + "-suby#{a}#{b}#{yield}"
            end
          end
        end

        it { should respond_to(:x_without_override!) }
        it { should respond_to(:y_without_override!) }
        specify { expect(instance.x!(1, 2) { '-block' }).to eq('parentx12-block-generatedx12-block-subx12-block') }
        specify { expect(instance.y!(1, 2) { '-block' }).to eq('parenty12-block-generatedy12-block-suby12-block') }
      end

      context "when does not support alias" do
        let(:parent) do
          Class.new do
            def method_missing(method_name, *args, &block)
              case method_name
                when :x? then "parentx#{args.join}#{yield}"
                when :y? then "parenty#{args.join}#{yield}"
                else super
              end
            end
          end
        end
        let(:klass) do
          Class.new(parent) do
            generate_methods(overrider: :override) do
              def x?(a, b, &block)
                super(a, b, &block) + "-generatedx#{a}#{b}#{yield}"
              end
              def y?(a, b, &block)
                super(a, b, &block) + "-generatedy#{a}#{b}#{yield}"
              end
            end
            def x?(a, b)
              super + "-subx#{a}#{b}#{yield}"
            end
            def y?(a, b)
              super + "-suby#{a}#{b}#{yield}"
            end
          end
        end

        it { should_not respond_to(:x_without_override?) }
        it { should_not respond_to(:y_without_override?) }
        specify { expect(instance.x?(1, 2) { '-block' }).to eq('parentx12-block-generatedx12-block-subx12-block') }
        specify { expect(instance.y?(1, 2) { '-block' }).to eq('parenty12-block-generatedy12-block-suby12-block') }
      end
    end
  end
end