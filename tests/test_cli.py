
import pytest
from rstxml2db.cli import prepareparams, parsecli


@pytest.mark.parametrize('params, expected', [
    (["a=2"],                   [('a', '2')]),
    (["a=2", "b=3"],            [('a', '2'), ('b', '3')]),
    (["a =2", "b= 3"],          [('a', '2'), ('b', '3')]),
    (["a = 2", "b = 3"],        [('a', '2'), ('b', '3')]),
    (["a.x = abc", "b.y = 4"],  [('a.x', 'abc'), ('b.y', '4')]),
    (["a=2", "b"],              [('a', '2')]),
    (["a=2", "b ="],            [('a', '2'), ('b', '')]),
])
def test_prepareparams(params, expected):
    result = prepareparams(params)
    assert result == expected


@pytest.mark.parametrize('cli,expected', [
  (['a.xml'], dict(indexfile='a.xml')),
  #
  (['--verbose', 'a.xml'],
   dict(verbose=1)
   ),
  (['-vv', 'a.xml'],
   dict(verbose=2)
   ),
  #
  (['-l', 'legal.xml', 'a.xml'],
   dict(legalnotice='legal.xml')
   ),
  (['--legalnotice', 'legal.xml', 'a.xml'],
   dict(legalnotice='legal.xml')
   ),
  #
  (['-c', 'preface.xml', 'a.xml'],
   dict(conventions='preface.xml')
   ),
  (['--conventions', 'preface.xml', 'a.xml'],
   dict(conventions='preface.xml')
   ),
  #
  (['-o', 'foo', 'a.xml'],
   dict(output='foo')
   ),
  (['--output', 'foo', 'a.xml'],
   dict(output='foo')
   ),
  #
  (['-k', 'a.xml'],
   dict(keepallids=False)
   ),
  (['--keep-all-ids', 'a.xml'],
   dict(keepallids=False)
   ),
  #
  (['-N', 'Foo', 'a.xml'],
   dict(_productname='Foo')
   ),
  (['--productname', 'Foo', 'a.xml'],
   dict(_productname='Foo')
   ),
  #
  (['-P', '42', 'a.xml'],
   dict(_productnumber='42')
   ),
  (['--productnumber', '42', 'a.xml'],
   dict(_productnumber='42')
   ),
  (['--productname', 'Foo', '--productnumber', '42', 'a.xml'],
   dict(_productname='Foo', _productnumber='42')
   ),
  #
  (['-p', 'a=2', '-p', 'b=4', 'a.xml'],
   dict(params=[('a', '2'), ('b', '4')])
   ),
  (['--param', 'a=2', '--param', 'b=4', 'a.xml'],
   dict(params=[('a', '2'), ('b', '4')])
   ),
  #
  (['-4', 'a.xml'],
   dict(db4=True)
   ),
  (['--db4', 'a.xml'],
   dict(db4=True)
   ),
])
def test_parsecli(cli, expected):
    result = parsecli(cli)
    # Create set difference and only compare this with the expected dictionary
    diff = set(result.__dict__) & set(expected)
    result = {i: getattr(result, i) for i in diff}
    assert result == expected
