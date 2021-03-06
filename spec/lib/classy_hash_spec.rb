# Classy Hash: Keep Your Hashes Classy (RSpec test suite)
# Created May 2014 by Mike Bourgeous, DeseretBook.com
# Copyright (C)2016 Deseret Book
# See LICENSE and README.md for details.

describe ClassyHash do
  # A list of test data and expected values for automated integration test creation
  classy_data = [
    {
      # Name of the data category
      name: 'simple',

      # Schema for this data category
      schema: {
        k1: String,
        k2: Numeric,
        k3: Integer,
        k4: TrueClass,
        k5: /\Ah.*d\z/i,
        k6: /H.*d/,
      },

      # Good hashes for this schema
      good: [
        { k1: 'V1', k2: 2, k3: 3, k4: true, k5: 'Hello, World', k6: 'I say, Hello, World!' },
        { k1: 'Val1', k2: 2.2, k3: -3, k4: false, k5: 'HOLD', k6: 'Hold' },
        { k1: 'V1', k2: Rational(-2, 7), k3: 0, k4: true, k5: 'hi world', k6: 'Hola, World' },
      ],

      # Bad hashes for this schema, with expected error message (string or regex)
      bad: [
        [ /^:k1.*present/, { } ],
        [ /^:k1/, { k1: :optional, k2: 2, k3: 3, k4: true, k5: 'hd', k6: 'Hd' } ],
        [ /^:k2/, { k1: '', k2: nil, k3: 3, k4: true, k5: 'hd', k6: 'Hd' } ],
        [ /^:k3/, { k1: '', k2: 0, k3: 3.3, k4: true, k5: 'hd', k6: 'Hd' } ],
        [ /^:k4/, { k1: '', k2: 0, k3: 3, k4: 'invalid', k5: 'hd', k6: 'Hd' } ],
        [ /^:k5.*String.*match/, { k1: '', k2: 0, k3: 3, k4: true, k5: nil, k6: 'Hd' } ],
        [ /^:k5.*String.*match/, { k1: '', k2: 0, k3: 3, k4: true, k5: 'Not hd', k6: 'Hd' } ],
        [ /^:k6.*String.*match/, { k1: '', k2: 0, k3: 3, k4: true, k5: 'HD', k6: 'hD' } ],
      ],
    },
    {
      name: 'ambiguous multiple choice',

      # Note: This is not the best way to structure multiple-choice schemas
      schema: {
        requests: [[
          {
            data: {
              field1: [String, Integer],
              field2: Integer,
              field3: [Integer, String]
            },
          },
          {
            data: {
              field1: String,
              field2: Integer,
              field3: Float,
            },
          },
        ]],
      },

      good: [
        { requests: [] },
        { requests: [
          { data: { field1: 1, field2: 2, field3: 'Three' } },
          { data: { field1: 'One', field2: 2, field3: 3.0 } },
        ] },
      ],

      # These bad schema tests are insufficiently specific and a bit fragile
      bad: [
        [
          %r{^:requests\[0\]\[:data\](\[:field1\] is not a/an String|\[:field3\] is not.*one of a/an Integer, a/an String)},
          { requests: [ { data: { field1: 1, field2: 2, field3: 3.0 } } ] },
        ],
        [
          %r{^:requests\[0\]\[:data\]\[:field2\] is not a/an Integer},
          { requests: [ { data: { field1: 'One', field2: 2.0, field3: 'Z' } } ] },
        ],
        [
          %r{^:requests\[1\]\[:data\](\[:field1\] is not a/an String|\[:field3\] is not.*one of a/an Integer, a/an String)},
          { requests: [
            { data: { field1: 'One', field2: 2, field3: 'Three' } },
            { data: { field1: 1, field2: 2, field3: nil } },
          ] },
        ],
      ],
    },
    {
      name: 'complex',

      schema: {
        k1: String,
        k2: String,
        k3: -10..10000,
        k4: Numeric,
        k5: FalseClass,
        k6: TrueClass,

        # :k7 must be a hash with this schema
        k7: {
          n1: String,
          n2: String,
          n3: {
            d1: Numeric
          }
        },

        # :k8 must be an array of integers or a String matching /ints/
        k8: [ [[Integer]], /ints/ ],

        # :k9 can be either nil or a hash with the specified schema
        k9: [
          NilClass,
          {
            opt1: [NilClass, String],
            opt2: [:optional, Numeric, Symbol, [[Integer]]],
            opt3: [[ { a: [NilClass, Integer] }, String ]], # Array of hashes or strings
            opt4: [[ [[ Integer ]] ]], # Array of arrays of integers
          }
        ],

        # :k10 must be an odd integer
        k10: lambda {|value| (value.is_a?(Integer) && value.odd?) ? true : 'an odd integer'},

        # :k11 can be missing, a string, or an array of integers, nils, and booleans
        k11: [:optional, String, [[Integer, NilClass, FalseClass]]]
      },

      good: [
        {
          k1: 'Value One',
          k2: 'Value Two',
          k3: -3,
          k4: 4.4,
          k5: true,
          k6: false,
          k7: {
            n1: 'Hi there',
            n2: 'This is a nested hash',
            n3: {
              d1: 5
            }
          },
          k8: [1, 2, 3, 4, 5],
          k9: {
            opt1: "opt1",
            opt2: 35,
            opt3: [
              {a: -5},
              {a: 6},
              'str3'
            ],
            opt4: [
              [1, 2, 3, 4, 5],
              (6..10).to_a,
              [],
              [-5, -10, -15],
            ]
          },
          k10: 7
          # :k11 is optional
        },
        {
          k1: 'V1',
          k2: 'V2',
          k3: -3,
          k4: 4.4,
          k5: true,
          k6: false,
          k7: {
            n1: 'Hi there',
            n2: 'This is a nested hash',
            n3: {
              d1: 5
            }
          },
          k8: [1, 2, 3, 4, 5],
          k9: {
            opt1: nil,
            opt2: :sym1,
            opt3: [
              {a: -5},
              {a: nil},
              'str3'
            ],
            opt4: []
          },
          k10: -3,
          k11: 'K11 can be a string'
        },
        {
          k1: 'V1',
          k2: 'V2',
          k3: -3,
          k4: 4.4,
          k5: true,
          k6: false,
          k7: {
            n1: 'Hi there',
            n2: 'This is a nested hash',
            n3: {
              d1: 5
            }
          },
          k8: [1, 2, 3, 4, 5],
          k9: {
            opt1: "opt1",
            opt3: [
              {a: -5},
              {a: nil},
              'str3'
            ],
            opt4: [
              [1, 2, 3, 4, 5],
              (6..10).to_a,
              [],
              [-5, -10, -15],
            ]
          },
          k10: -3,
          k11: 'K11 is a string here'
        },
        {
          k1: 'V1',
          k2: 'V2',
          k3: -3,
          k4: 4.4,
          k5: true,
          k6: false,
          k7: {
            n1: 'Hi there',
            n2: 'This is a nested hash',
            n3: {
              d1: 0.35
            }
          },
          k8: [1, 2, 3, 4, 5],
          k9: {
            opt1: "opt1",
            opt2: [1, 2, 3],
            opt3: [
              {a: -5},
              {a: nil},
              'str3'
            ],
            opt4: [
              [1, 2, 3, 4, 5],
              (6..10).to_a,
              [],
              [-5, -10, -15],
            ]
          },
          k10: -3,
          k11: [
            3,
            4,
            5,
            nil,
            true,
            false,
            1<<150
          ]
        },
        {
          k1: 'V1',
          k2: 'V2',
          k3: -3,
          k4: 4.4,
          k5: true,
          k6: false,
          k7: {
            n1: 'Hi there',
            n2: 'This is a nested hash',
            n3: {
              d1: 0.35
            }
          },
          k8: 'some ints would normally be here',
          k9: {
            opt1: "opt1",
            opt2: [1, 2, 3],
            opt3: [
              {a: -5},
              {a: nil},
              'str3'
            ],
            opt4: [
              [1, 2, 3, 4, 5],
              (6..10).to_a,
              [],
              [-5, -10, -15],
            ]
          },
          k10: -3,
          k11: [
            3,
            4,
            5,
            nil,
            true,
            false,
            1<<150
          ]
        },
      ],

      bad: [
        [ /^:k1/, { k1: :v1 } ],
        [ /^:k1/, { k2: 5 } ],
        [ /^:k3.*range/, { k1: 'V1', k2: 'V2', k3: -600, } ],
        [ /^:k5/, { k1: 'V1', k2: 'V2', k3: 5, k4: 1.0, k5: 'true' } ],
        [ /^:k7.*hash/i, { k1: '1', k2: '2', k3: 3, k4: 4, k5: false, k6: true, k7: 'x' } ],
        [
          /^:k7\[:n3\]\[:d1\]/,
          {
            k1: '1',
            k2: '2',
            k3: 3,
            k4: 4,
            k5: false,
            k6: true,
            k7: {
              n1: 'N1',
              n2: 'N2',
              n3: {
                d1: 'No'
              }
            }
          }
        ],
        [
          /^:k9.*\[:opt2\].*one of/,
          {
            k1: '1',
            k2: '2',
            k3: 3,
            k4: 4,
            k5: false,
            k6: true,
            k7: {
              n1: 'N1',
              n2: 'N2',
              n3: {
                d1: 333
              }
            },
            k8: [1],
            k9: {
              opt1: "opt1",
              opt2: nil,
              opt3: [
                {a: 5},
                {a: nil},
                {a: 3.35},
                7
              ]
            }
          }
        ],
        [
          /^:k9.*\[:opt3\]\[2\].*one of/,
          {
            k1: '1',
            k2: '2',
            k3: 3,
            k4: 4,
            k5: false,
            k6: true,
            k7: {
              n1: 'N1',
              n2: 'N2',
              n3: {
                d1: 333
              }
            },
            k8: [1],
            k9: {
              opt1: "opt1",
              opt2: 35,
              opt3: [
                {a: 5},
                {a: nil},
                {a: 3.35},
                7
              ]
            }
          }
        ],
        [
          /^:k10.*odd/,
          {
            k1: '1',
            k2: '2',
            k3: 3,
            k4: 4,
            k5: false,
            k6: true,
            k7: {
              n1: 'N1',
              n2: 'N2',
              n3: {
                d1: 333
              }
            },
            k8: [1],
            k9: {
              opt1: "opt1",
              opt2: 35,
              opt3: [
                {a: 5},
                {a: nil},
                '7'
              ],
              opt4: []
            },
            k10: 1.7
          }
        ],
        [
          /^:k9.*\[:opt4\]\[1\]\[3\]/,
          {
            k1: 'V1',
            k2: 'V2',
            k3: -3,
            k4: 4.4,
            k5: true,
            k6: false,
            k7: {
              n1: 'Hi there',
              n2: 'This is a nested hash',
              n3: {
                d1: 0.35
              }
            },
            k8: [1, 2, 3, 4, 5],
            k9: {
              opt1: "opt1",
              opt3: [
                {a: -5},
                {a: nil},
                'str3'
              ],
              opt4: [
                [1],
                [3, 5, 9, 10.0],
                [],
                [-10, -15],
              ]
            },
            k10: -3,
            k11: [
              3,
              4,
              5,
              nil,
              true,
              false,
              1
            ]
          }
        ],
        [
          /^:k11.*:k11\[6\]/,
          {
            k1: 'V1',
            k2: 'V2',
            k3: -3,
            k4: 4.4,
            k5: true,
            k6: false,
            k7: {
              n1: 'Hi there',
              n2: 'This is a nested hash',
              n3: {
                d1: 0.35
              }
            },
            k8: [1, 2, 3, 4, 5],
            k9: {
              opt1: "opt1",
              opt3: [
                {a: -5},
                {a: nil},
                'str3'
              ],
              opt4: [
                [1, 2, 3, 4, 5],
                (6..10).to_a,
                [],
                [-5, -10, -15],
              ]
            },
            k10: -3,
            k11: [
              3,
              4,
              5,
              nil,
              true,
              false,
              1.5
            ]
          }
        ],
        [
          /^:k8.*\/ints\//,
          {
            k1: 'V1',
            k2: 'V2',
            k3: -3,
            k4: 4.4,
            k5: true,
            k6: false,
            k7: {
              n1: 'Hi there',
              n2: 'This is a nested hash',
              n3: {
                d1: 0.35
              }
            },
            k8: 'There are no integers here',
            k9: {
              opt1: "opt1",
              opt3: [
                {a: -5},
                {a: nil},
                'str3'
              ],
              opt4: [
                [1, 2, 3, 4, 5],
                (6..10).to_a,
                [],
                [-5, -10, -15],
              ]
            },
            k10: -3,
            k11: [
              3,
              4,
              5,
              nil,
              true,
              false,
              1<<150
            ]
          }
        ],
        [
          /^:k9.*\[:opt4\].*Array/,
          {
            k1: 'V1',
            k2: 'V2',
            k3: -3,
            k4: 4.4,
            k5: true,
            k6: false,
            k7: {
              n1: 'Hi there',
              n2: 'This is a nested hash',
              n3: {
                d1: 0.35
              }
            },
            k8: 'some ints would normally be here',
            k9: {
              opt1: "opt1",
              opt2: [1, 2, 3],
              opt3: [
                {a: -5},
                {a: nil},
                'str3'
              ],
              opt4: :not_an_array,
            },
            k10: -3,
            k11: [
              3,
              4,
              5,
              nil,
              true,
              false,
              1<<150
            ]
          },
        ],
      ]
    }
  ]

  # Granular tests
  describe '.validate' do
    it 'accepts basic valid values' do
      expect{ ClassyHash.validate({a: 'hi'}, {a: String}) }.not_to raise_error
      expect{ ClassyHash.validate({a: 3}, {a: Numeric}) }.not_to raise_error
      expect{ ClassyHash.validate({a: :sym1}, {a: Symbol}) }.not_to raise_error
      expect{ ClassyHash.validate({a: {q: :q}}, {a: Hash}) }.not_to raise_error
      expect{ ClassyHash.validate({a: [:q, :q]}, {a: Array}) }.not_to raise_error
    end

    it 'rejects basic invalid values' do
      expect{ ClassyHash.validate({a: nil}, {a: String}) }.to raise_error(/not.*String/)
      expect{ ClassyHash.validate({a: 3}, {a: String}) }.to raise_error(/not.*String/)
      expect{ ClassyHash.validate({a: false}, {a: Numeric}) }.to raise_error(/not.*Numeric/)
      expect{ ClassyHash.validate({a: {q: :q}}, {a: Array}) }.to raise_error(/not.*Array/)
      expect{ ClassyHash.validate({a: [:q, :q]}, {a: Hash}) }.to raise_error(/not.*Hash/)
    end

    it 'accepts fixnum, bignum, float, and rational for numeric' do
      expect{ ClassyHash.validate({a: 0}, {a: Numeric}) }.not_to raise_error
      expect{ ClassyHash.validate({a: 1<<200}, {a: Numeric}) }.not_to raise_error
      expect{ ClassyHash.validate({a: 1.0123}, {a: Numeric}) }.not_to raise_error
      expect{ ClassyHash.validate({a: Rational(1, 3)}, {a: Numeric}) }.not_to raise_error
    end

    it 'rejects float and rational for integer' do
      expect{ ClassyHash.validate({a: 1.0}, {a: Integer}) }.to raise_error(/not.*(Integer|Fixnum)/)
      expect{ ClassyHash.validate({a: Rational(1, 3)}, {a: Integer}) }.to raise_error(/not.*(Integer|Fixnum)/)
    end

    it 'accepts valid multiple choice values' do
      expect{ ClassyHash.validate({a: nil}, {a: [NilClass]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: 'hello'}, {a: [String]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: 'str'}, {a: [String, Rational, NilClass]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: Rational(-3, 5)}, {a: [String, Rational, NilClass]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: nil}, {a: [String, Rational, NilClass]}) }.not_to raise_error
    end

    it 'rejects invalid multiple choice values' do
      expect{ ClassyHash.validate({a: nil}, {a: [String]}) }.to raise_error(/one of.*String/)
      expect{ ClassyHash.validate({a: false}, {a: [NilClass]}) }.to raise_error(/one of.*Nil/)
      expect{ ClassyHash.validate({a: 1}, {a: [String]}) }.to raise_error(/one of.*String/)
      expect{ ClassyHash.validate({a: 1}, {a: [String, Rational, NilClass]}) }.to raise_error(/one of.*String.*Rational.*Nil/)
    end

    it 'starts with the closest matching schema for errors from multiple-choice schemas when full is false' do
      schema = {
        a: [{ a: Integer }, { b: String }]
      }

      expect{ ClassyHash.validate({a: {a: 'A'}}, schema) }.to raise_error(%r{^:a\[:a\] is not a/an Integer})
      expect{ ClassyHash.validate({a: {b: 1}}, schema) }.to raise_error(%r{^:a\[:b\] is not a/an String})

      expect{ ClassyHash.validate({a: {a: 1}}, schema) }.not_to raise_error
      expect{ ClassyHash.validate({a: {b: 'A'}}, schema) }.not_to raise_error
    end

    it 'accepts both true and false for just TrueClass or just FalseClass' do
      expect{ ClassyHash.validate({a: true}, {a: TrueClass}) }.not_to raise_error
      expect{ ClassyHash.validate({a: false}, {a: TrueClass}) }.not_to raise_error
      expect{ ClassyHash.validate({a: true}, {a: FalseClass}) }.not_to raise_error
      expect{ ClassyHash.validate({a: false}, {a: FalseClass}) }.not_to raise_error

      expect{ ClassyHash.validate({a: true}, {a: [FalseClass]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: false}, {a: [TrueClass]}) }.not_to raise_error
    end

    it 'rejects invalid values for TrueClass and FalseClass' do
      expect{ ClassyHash.validate({a: 1}, {a: TrueClass}) }.to raise_error(/true or false/)
      expect{ ClassyHash.validate({a: 0}, {a: FalseClass}) }.to raise_error(/true or false/)
      expect{ ClassyHash.validate({a: 1}, {a: [TrueClass]}) }.to raise_error(/one of.*true or false/)
      expect{ ClassyHash.validate({a: 0}, {a: [FalseClass]}) }.to raise_error(/one of.*true or false/)
    end

    it 'requires both TrueClass and FalseClass for true or false in multiple choices' do
      expect{ ClassyHash.validate({a: true}, {a: [TrueClass, FalseClass]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: false}, {a: [TrueClass, FalseClass]}) }.not_to raise_error
    end

    it 'accepts valid single-choice arrays' do
      expect{ ClassyHash.validate({a: []}, {a: [[String]]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: ['hi']}, {a: [[String]]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: [1]}, {a: [[Integer]]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: [1, 2, 3, 4, 5]}, {a: [[Integer]]}) }.not_to raise_error
    end

    it 'rejects invalid single-choice arrays' do
      expect{ ClassyHash.validate({a: [nil]}, {a: [[String]]}) }.to raise_error(/\[0\].*String/)
      expect{ ClassyHash.validate({a: ['hi', 'hello', 'heya', :optional]}, {a: [[String]]}) }.to raise_error(/\[3\].*String/)
      expect{ ClassyHash.validate({a: [1]}, {a: [[String]]}) }.to raise_error(/\[0\].*String/)
      expect{ ClassyHash.validate({a: [1, 2, 3, '']}, {a: [[Integer]]}) }.to raise_error(/\[3\].*Integer/)
    end

    it 'accepts valid multiple-choice arrays' do
      expect{ ClassyHash.validate({a: []}, {a: [[String, NilClass, Integer]]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: ['str']}, {a: [[String, NilClass, Integer]]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: [nil]}, {a: [[String, NilClass, Integer]]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: [1, 2, 3]}, {a: [[String, NilClass, Integer]]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: [1, nil, 'str', 4]}, {a: [[String, NilClass, Integer]]}) }.not_to raise_error
    end

    it 'rejects invalid multiple-choice arrays' do
      schema = { a: [[String, TrueClass, Float]] }
      expect{ ClassyHash.validate({a: [nil]}, schema) }.to raise_error(/\[0\].*String.*true or false.*Float/)
      expect{ ClassyHash.validate({a: ['hi', 'hello', 'heya', :optional]}, schema) }.to raise_error(/\[3\].*String.*true or false.*Float/)
      expect{ ClassyHash.validate({a: [1]}, schema) }.to raise_error(/\[0\].*String.*true or false.*Float/)
      expect{ ClassyHash.validate({a: [1, 2, 3, '']}, {a: [[Integer, Float]]}) }.to raise_error(/\[3\].*Integer.*Float/)
    end

    it 'accepts valid arrays with schemas' do
      expect { ClassyHash.validate({a: [{b: 1}, {b: 2.1}, 5]}, {a: [[{b: Numeric}, Integer]]}) }.not_to raise_error
    end

    it 'rejects invalid arrays with schemas' do
      expect { ClassyHash.validate({a: [{c: 1}, {b: 2.1}, 5]}, {a: [[{b: Numeric}, Integer]]}, full: true) }.to raise_error(/present/)
      expect { ClassyHash.validate({a: [{b: 1}, {b: 2.1}, 5.0]}, {a: [[{b: Numeric}, Integer]]}) }.to raise_error(/\[2\]/)
    end

    it 'handles more than one key' do
      expect{ ClassyHash.validate({a: true, b: 'str'}, {a: TrueClass, b: String}) }.not_to raise_error
      expect{ ClassyHash.validate({a: 'str', b: true}, {a: TrueClass, b: String}) }.to raise_error(/:a.*true or false/)
    end

    it 'rejects hashes with missing keys' do
      expect{ ClassyHash.validate({}, {a: NilClass}) }.to raise_error(/:a.*present/)
      expect{ ClassyHash.validate({}, {a: Integer}) }.to raise_error(/:a.*present/)
      expect{ ClassyHash.validate({a: 1}, {a: Integer, b: NilClass}) }.to raise_error(/:b.*present/)
    end

    it 'accepts valid or missing optional keys' do
      expect{ ClassyHash.validate({}, {a: [:optional, Integer]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: 1}, {a: [:optional, Integer]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: 1<<200}, {a: [:optional, Integer]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: 'str'}, {a: [:optional, Integer, String]}) }.not_to raise_error
    end

    it 'accepts valid or missing optional arrays' do
      expect{ ClassyHash.validate({}, {a: [:optional, [[Integer]] ]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: []}, {a: [:optional, [[Integer]] ]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: [1, 2, 3]}, {a: [:optional, [[Integer]] ]}) }.not_to raise_error
    end

    it 'rejects invalid optional keys' do
      expect{ ClassyHash.validate({a: nil}, {a: [:optional, Integer]}) }.to raise_error(/:a.*Integer/)
      expect{ ClassyHash.validate({a: 'str'}, {a: [:optional, Integer]}) }.to raise_error(/:a.*Integer/)
      expect{ ClassyHash.validate({a: :sym1}, {a: [:optional, Integer, String]}) }.to raise_error(/:a.*one of.*Integer.*String/)
    end

    it 'rejects invalid optional arrays' do
      expect{ ClassyHash.validate({a: [5.5]}, {a: [:optional, [[Integer]] ]}) }.to raise_error(/\[0\].*Integer/)
      expect{ ClassyHash.validate({a: [1, 2, 3, 'str']}, {a: [:optional, [[Integer]] ]}) }.to raise_error(/\[3\]/)
    end

    it 'accepts missing optional member with proc that would always fail' do
      # We can ensure a member is *never* present with this construct
      expect{ ClassyHash.validate({}, {a: [:optional, lambda {|v| false}]}) }.not_to raise_error
      expect{ ClassyHash.validate({a: nil}, {a: [:optional, lambda {|v| false}]}) }.to raise_error(/accepted by/)
    end

    it 'accepts or rejects hashes using a proc' do
      expect{ ClassyHash.validate({a: 1}, {a: lambda {|v| v == 1}}) }.not_to raise_error
      expect{ ClassyHash.validate({a: -1}, {a: lambda {|v| v == 1}}) }.to raise_error(/accepted by.*Proc/)
    end

    it 'uses error messages returned by a proc' do
      expect{ ClassyHash.validate({a: 1}, {a: lambda {|v| 'no way'}}) }.to raise_error(/no way/)
    end

    it 'accepts valid values using a range' do
      expect{ ClassyHash.validate({a: 1}, {a: 1..2}) }.not_to raise_error
      expect{ ClassyHash.validate({a: Rational(3, 2)}, {a: 1.0..2.0}) }.not_to raise_error
      expect{ ClassyHash.validate({a: 'carrot'}, {a: 'cabbage'..'cauliflower'}) }.not_to raise_error
      expect{ ClassyHash.validate({a: [1, 1]}, {a: [0]..[2]}) }.not_to raise_error
    end

    it 'rejects out-of-range values using a range' do
      expect{ ClassyHash.validate({a: 0}, {a: 1..2}) }.to raise_error(/in range/)
      expect{ ClassyHash.validate({a: Rational(1, 2)}, {a: 1.0..2.0}) }.to raise_error(/in range/)
      expect{ ClassyHash.validate({a: 'spinach'}, {a: 'cabbage'..'cauliflower'}) }.to raise_error(/in range/)
      expect{ ClassyHash.validate({a: [2, 1]}, {a: [0]..[2]}) }.to raise_error(/in range/)
    end

    it 'rejects invalid types using a range' do
      expect{ ClassyHash.validate({a: 1.0}, {a: 1..2}) }.to raise_error(/Integer/)
      expect{ ClassyHash.validate({a: 1}, {a: 'a'..'z'}) }.to raise_error(/String/)
    end

    it 'accepts valid values using a Set' do
      expect{ ClassyHash.validate({a: 1}, {a: Set.new([1, '2', 3, nil])}) }.not_to raise_error
      expect{ ClassyHash.validate({a: '2'}, {a: Set.new([1, '2', 3, nil])}) }.not_to raise_error
      expect{ ClassyHash.validate({a: 3}, {a: Set.new([1, '2', 3, nil])}) }.not_to raise_error
      expect{ ClassyHash.validate({a: nil}, {a: Set.new([1, '2', 3, nil])}) }.not_to raise_error
    end

    it 'rejects invalid values using a Set' do
      # Empty set
      expect{ ClassyHash.validate({a: 1}, {a: Set.new}) }.to raise_error(/element.*\[\]/)
      expect{ ClassyHash.validate({a: nil}, {a: Set.new}) }.to raise_error(/element.*\[\]/)
      expect{ ClassyHash.validate({b: :missing}, {a: Set.new}) }.to raise_error(/not present/)

      # Non-empty set
      expect{ ClassyHash.validate({a: '1'}, {a: Set.new([1, '2', 3, nil])}) }.to raise_error(/element/)
      expect{ ClassyHash.validate({a: 2}, {a: Set.new([1, '2', 3, nil])}) }.to raise_error(/element/)
      expect{ ClassyHash.validate({a: nil}, {a: Set.new([1, '2', 3])}) }.to raise_error(/element/)
      expect{ ClassyHash.validate({b: :missing}, {a: Set.new([1, '2', 3, nil])}) }.to raise_error(/not present/)
    end

    it 'rejects non-hashes' do
      expect{ ClassyHash.validate(false, {}) }.to raise_error(/not a Hash/)
      expect{ ClassyHash.validate({}, false) }.to raise_error(/not a.*constraint/)
    end

    it 'rejects invalid schema elements' do
      expect{ ClassyHash.validate({a: 1}, {a: :invalid}) }.to raise_error(/valid.*constraint/)
    end

    it 'rejects empty multiple choice constraints' do
      expect{ ClassyHash.validate({a: nil}, {a: []}) }.to raise_error(/choice.*empty/)
      expect{ ClassyHash.validate({a: [1]}, {a: [[]]}) }.to raise_error(/choice.*empty/)
    end

    it 'accepts or rejects Strings using a partial-string regex' do
      schema = { a: /(in)?[1-9]{1,3}/ }
      expect{ ClassyHash.validate({a: 3}, schema) }.to raise_error(/String.*match/)
      expect{ ClassyHash.validate({a: 3.to_s}, schema) }.not_to raise_error
      expect{ ClassyHash.validate({a: nil}, schema) }.to raise_error(/String.*match/)
      expect{ ClassyHash.validate({a: 'in0'}, schema) }.to raise_error(/String.*match/)
      expect{ ClassyHash.validate({a: 'in1'}, schema) }.not_to raise_error
      expect{ ClassyHash.validate({a: 'the middle can be in923 ok'}, schema) }.not_to raise_error
    end

    it 'accepts or rejects Strings using a whole-string regex' do
      schema = { a: /\Athe.*string\z/i }
      expect{ ClassyHash.validate({a: /the string/}, schema) }.to raise_error(/String.*match/)
      expect{ ClassyHash.validate({a: 'not the string'}, schema) }.to raise_error(/String.*match/)
      expect{ ClassyHash.validate({a: 'The WHOLE String'}, schema) }.not_to raise_error
    end

    it 'accepts any value for :optional (undocumented)' do
      expect{ ClassyHash.validate({a: nil}, {a: :optional}) }.not_to raise_error
      expect{ ClassyHash.validate({a: 1}, {a: :optional}) }.not_to raise_error
      expect{ ClassyHash.validate({a: ['a', 'b']}, {a: :optional}) }.not_to raise_error
      expect{ ClassyHash.validate({a: {}}, {a: :optional}) }.not_to raise_error
    end

    it 'allows nil to be used as a key' do
      expect{ ClassyHash.validate({nil => 3}, {nil => Integer}) }.not_to raise_error
      expect{ ClassyHash.validate({nil => 3}, {nil => String}) }.to raise_error(/nil .*String/)
      expect{ ClassyHash.validate({nil => {nil => 3}}, {nil => {nil => String}}) }.to raise_error(/nil\[nil\] .*String/)
    end

    it 'does not collect all errors by default' do
      schema = { a: String, b: String }
      ex = begin
             ClassyHash.validate({ a: 1, b: 1 }, schema)
           rescue => e
             e
           end

      expect(ex.message).to match(/:a/)
      expect(ex.message).not_to match(/:b/)
      expect(ex.entries.length).to eq(1)
    end

    it 'handles invalid data passed in the errors array' do
      expect{ ClassyHash.validate({}, {}, errors: ['invalid']) }.to raise_error(/ERR:.*invalid/)
    end

    context 'schema is empty' do
      it 'accepts all hashes' do
        expect{ ClassyHash.validate({}, {}) }.not_to raise_error
        expect{ ClassyHash.validate({a: 1}, {}) }.not_to raise_error
        expect{ ClassyHash.validate({[1] => [2]}, {}) }.not_to raise_error
        expect{ ClassyHash.validate({ {} => {} }, {}) }.not_to raise_error
      end
    end
  end

  describe '.validate_strict' do
    it 'rejects non-hashes' do
      expect{ ClassyHash.validate_strict(false, {}) }.to raise_error(/not a Hash/)
      expect{ ClassyHash.validate_strict({}, false) }.to raise_error(/not a.*constraint/)
    end

    context 'schema is empty' do
      it 'rejects all non-empty hashes' do
        expect{ ClassyHash.validate_strict({}, {}) }.not_to raise_error
        expect{ ClassyHash.validate_strict({a: 1}, {}) }.to raise_error(/not specified/)
        expect{ ClassyHash.validate_strict({[1] => [2]}, {}) }.to raise_error(/not specified/)
        expect{ ClassyHash.validate_strict({ {} => {} }, {}) }.to raise_error(/not specified/)
      end
    end
  end

  describe '.validate(raise_errors: false)' do
    it 'returns true for valid hashes' do
      expect(ClassyHash.validate({ a: 1 }, { a: Integer }, raise_errors: false)).to eq(true)
    end

    it 'returns false for invalid hashes' do
      expect(ClassyHash.validate({ a: 1.0 }, { a: Integer }, raise_errors: false)).to eq(false)
    end

    it 'rejects invalid schema elements' do
      errors = []
      expect(ClassyHash.validate({a: 1}, {a: :invalid}, raise_errors: false, errors: errors)).to eq(false)
      expect(errors.inspect).to match(/valid.*constraint/)
    end

    it 'does not collect all errors by default' do
      schema = { a: String, b: String }
      hash = { a: 1, b: 2 }
      errors = []
      expect(ClassyHash.validate(hash, schema, raise_errors: false, errors: errors)).to eq(false)
      expect(errors.length).to eq(1)
      expect(errors.inspect).to match(/:a/)
      expect(errors.inspect).not_to match(/:b/)
    end
  end

  describe '.validate(full: true)' do
    it 'collects all errors' do
      schema = {a: String, b: { c: String }}
      expect{ ClassyHash.validate({ a: 1, b: {} }, schema, full: true) }.to raise_error(%r{:a is not a\/an String, :b\[:c\] is not present})
      expect{ ClassyHash.validate({ a: 'hey', b: { c: 'hello' } }, schema, full: true) }.not_to raise_error
    end

    it 'collects all invalid schema elements' do
      expect{ ClassyHash.validate({a: :a, b: :b}, {a: :invalid, b: :invalid}, full: true) }.to raise_error(/:a.*valid.*constraint.*:b.*valid.*constraint/)
    end

    it 'can store errors in an external array for application handling' do
      entries = []

      ClassyHash.validate({a: 1, b: {} }, {a: String, b: { c: String }},
                          raise_errors: false, full: true, errors: entries)

      expect(entries).to eq [
        { full_path: ':a', message: 'a/an String' },
        { full_path: ':b[:c]', message: 'present' }
      ]
    end

    it 'stores errors in an array on the exception object' do
      ex = begin
             ClassyHash.validate({a: 1, b: {} }, {a: String, b: { c: String }}, full: true)
           rescue => e
             e
           end

      expect(ex.entries).to eq [
        { full_path: ':a', message: 'a/an String' },
        { full_path: ':b[:c]', message: 'present' }
      ]
    end

    it 'can collect errors from range types' do
      schema = {a: 1..10, b: 1.0..10.0, c: '1'..'9', d: [0]..[9]}
      hash = {a: 5.0, b: 'five', c: 5, d: [500]}
      expect{ ClassyHash.validate(hash, schema, full: true) }.to raise_error(/:a.*Integer.*:b.*Numeric.*:c.*String.*:d.*in range/)

      errors = []
      expect(ClassyHash.validate(hash, schema, full: true, raise_errors: false, errors: errors)).to eq(false)
      expect(errors.count).to eq(4)
    end

    context 'strict is true' do
      let(:schema) {
        {
          a: {},
          b: {},
          c: {},
          d: [[{}]], # An array of empty Hashes
        }
      }

      let(:hash) {
        {
          a: { k000: 0, k001: 1 },
          b: { k002: 2, k003: 3 },
          c: { k004: 4, k005: 5 },
          d: [{}, {}, {}, { not_empty: true, at_all: true }],
          k006: 6,
          k007: 7,
        }
      }

      it 'accepts a valid hash' do
        expect{
          ClassyHash.validate({a: {}, b: {}, c: {}, d: [{}, {}, {}]}, schema, full: true, strict: true, verbose: true)
        }.not_to raise_error
      end

      it 'includes unexpected hash keys for all levels if verbose is true' do
        expect{
          ClassyHash.validate(hash, schema, full: true, strict: true, verbose: true)
        }.to raise_error(/Top level.*:k006, :k007.*:a.*:k000, :k001.*:b.*:k002, :k003.*:c.*:k004, :k005.*:d\[3\].*:not_empty, :at_all/)
      end
    end
  end

  # Integrated tests (see test data at the top of the file)
  classy_data.each do |d|
    describe '.validate' do
      context "schema is #{d[:name]}" do
        d[:good].each_with_index do |h, idx|
          it "accepts good hash #{idx}" do
            expect{ ClassyHash.validate(h, d[:schema]) }.not_to raise_error
          end

          it "accepts good hash #{idx} with extra members" do
            expect{ ClassyHash.validate(h.merge({k999: 'a', k000: :b}), d[:schema]) }.not_to raise_error
          end
        end

        d[:bad].each_with_index do |info, idx|
          it "rejects bad hash #{idx}" do
            expect{ ClassyHash.validate(info[1], d[:schema]) }.to raise_error(info[0])
          end
        end
      end
    end

    describe '.validate(strict: true)' do
      context "schema is #{d[:name]}" do
        d[:good].each_with_index do |h, idx|
          it "accepts good hash #{idx}" do
            expect{ ClassyHash.validate_strict(h, d[:schema]) }.not_to raise_error
          end

          it "rejects good hash #{idx} with extra members" do
            expect{ ClassyHash.validate_strict(h.merge({k999: 'a', k000: :b}), d[:schema]) }.to raise_error(/Top level.*contains members/)
          end

          it "includes all unexpected hash #{idx} keys in error message if verbose is set" do
            expect {
              ClassyHash.validate_strict(h.merge(k999: 'a', k000: :b), d[:schema], true)
            }.to raise_error(/contains members :k999, :k000 not specified in schema/)
          end
        end

        d[:bad].each_with_index do |info, idx|
          it "rejects bad hash #{idx}" do
            expect{ ClassyHash.validate_strict(info[1], d[:schema]) }.to raise_error(info[0])
          end
        end
      end
    end

    describe '.validate(full: true)' do
      context "schema is #{d[:name]}" do
        d[:good].each_with_index do |h, idx|
          it "accepts good hash #{idx}" do
            expect{ ClassyHash.validate(h, d[:schema], full: true) }.not_to raise_error
          end

          context 'strict parameter is false' do
            it "accepts good hash #{idx} with extra members" do
              expect{ ClassyHash.validate(h.merge({k999: 'a', k000: :b}), d[:schema], strict: false, full: true) }.not_to raise_error
            end
          end

          context 'strict parameter is true' do
            it "rejects good hash #{idx} with extra members" do
              expect{
                ClassyHash.validate(h.merge({k999: 'a', k000: :b}), d[:schema], strict: true, full: true)
              }.to raise_error(/members not specified in schema/)
            end

            it "includes all unexpected hash #{idx} keys if verbose is set" do
              expect{
                ClassyHash.validate(h.merge({k999: 'a', k000: :b}), d[:schema], strict: true, full: true, verbose: true)
              }.to raise_error(/members :k999, :k000 not specified in schema/)
            end
          end
        end

        d[:bad].each_with_index do |info, idx|
          it "rejects bad hash #{idx}" do
            expect{ ClassyHash.validate(info[1], d[:schema], full: true) }.to raise_error(info[0])
          end
        end
      end
    end
  end

  describe 'deep strict validation' do
    context 'when nested hash contains unexpected members' do
      let(:schema) do
        { nested: { id: Integer } }
      end

      let(:hash) do
        { nested: { id: 1, wutang: false } }
      end

      it 'rejects hash' do
        expect{ ClassyHash.validate(hash, schema, strict: true) }.to raise_error(/:nested .*contains members not/)
        expect{ ClassyHash.validate(hash, schema, strict: true, verbose: true) }.to raise_error(/:nested .*contains members :wutang not/)
      end
    end

    context 'when elements of child array contains unexpected members' do
      let(:schema) do
        { collection: [[{ id: Integer }]] }
      end

      let(:hash) do
        { collection: [{ id: 1, wutang: false }] }
      end

      it 'rejects hash' do
        expect{ ClassyHash.validate(hash, schema, strict: true) }.to raise_error(/:collection\[0\] .*contains members not/)
        expect{ ClassyHash.validate(hash, schema, strict: true, verbose: true) }.to raise_error(/:collection\[0\] .*contains members :wutang not/)
      end
    end
  end
end
