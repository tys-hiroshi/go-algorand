// Code generated by "stringer -type=GlobalField"; DO NOT EDIT.

package logic

import "strconv"

func _() {
	// An "invalid array index" compiler error signifies that the constant values have changed.
	// Re-run the stringer command to generate them again.
	var x [1]struct{}
	_ = x[MinTxnFee-0]
	_ = x[MinBalance-1]
	_ = x[MaxTxnLife-2]
	_ = x[ZeroAddress-3]
	_ = x[GroupSize-4]
	_ = x[invalidGlobalField-5]
}

const _GlobalField_name = "MinTxnFeeMinBalanceMaxTxnLifeZeroAddressGroupSizeinvalidGlobalField"

var _GlobalField_index = [...]uint8{0, 9, 19, 29, 40, 49, 67}

func (i GlobalField) String() string {
	if i < 0 || i >= GlobalField(len(_GlobalField_index)-1) {
		return "GlobalField(" + strconv.FormatInt(int64(i), 10) + ")"
	}
	return _GlobalField_name[_GlobalField_index[i]:_GlobalField_index[i+1]]
}
