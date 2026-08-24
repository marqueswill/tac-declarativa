#!/bin/sh
# ---------------------------------------------------------------------------
# Test suite for the MoreSTLC front end.
#
# These tests exercise the *front end* only (grammar, parser, pretty printer),
# so they pass even while the type checker and the evaluator are still stubs.
# Run them after every change to MoreSTLC.cf.
# ---------------------------------------------------------------------------
EXE=./morestlc
# every file that must parse: everything except the deliberately broken one
GOOD=`ls examples/*.mstlc examples/bad/*.mstlc | grep -v 'parse-error'`
BROKEN=examples/bad/parse-error.mstlc
fail=0

echo "== 1. the grammar must be unambiguous =========================="
mkdir -p build
conflicts=`${HAPPY:-happy} -gca gen/ParMoreSTLC.y -o build/conflict-check.hs 2>&1`
if [ -n "$conflicts" ]; then
  echo "FAIL: happy reported conflicts:"
  echo "$conflicts"
  fail=1
else
  echo "OK: happy reports 0 shift/reduce and 0 reduce/reduce conflicts"
fi

echo
echo "== 2. every example must parse ================================="
for f in $GOOD; do
  $EXE --parse-only "$f" >/dev/null || { echo "FAIL: $f did not parse"; fail=1; }
done
echo "OK: `echo $GOOD | wc -w` files parsed"

echo
echo "== 3. pretty printing must round trip =========================="
for f in $GOOD; do
  $EXE --roundtrip "$f" >/dev/null || { echo "FAIL: $f did not round trip"; fail=1; }
done
echo "OK: `echo $GOOD | wc -w` files round tripped"

echo
echo "== 4. broken syntax must be rejected ==========================="
if $EXE --parse-only "$BROKEN" >/dev/null 2>&1; then
  echo "FAIL: $BROKEN parsed, but it should not"
  fail=1
else
  echo "OK: $BROKEN rejected with a parse error"
fi

echo
if [ $fail -eq 0 ]; then
  echo "all front end tests passed"
else
  echo "SOME TESTS FAILED"
fi
exit $fail
