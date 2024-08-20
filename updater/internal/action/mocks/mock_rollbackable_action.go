// Code generated by mockery v2.44.2. DO NOT EDIT.

package mocks

import mock "github.com/stretchr/testify/mock"

// MockRollbackableAction is an autogenerated mock type for the RollbackableAction type
type MockRollbackableAction struct {
	mock.Mock
}

// Rollback provides a mock function with given fields:
func (_m *MockRollbackableAction) Rollback() error {
	ret := _m.Called()

	if len(ret) == 0 {
		panic("no return value specified for Rollback")
	}

	var r0 error
	if rf, ok := ret.Get(0).(func() error); ok {
		r0 = rf()
	} else {
		r0 = ret.Error(0)
	}

	return r0
}

// NewMockRollbackableAction creates a new instance of MockRollbackableAction. It also registers a testing interface on the mock and a cleanup function to assert the mocks expectations.
// The first argument is typically a *testing.T value.
func NewMockRollbackableAction(t interface {
	mock.TestingT
	Cleanup(func())
}) *MockRollbackableAction {
	mock := &MockRollbackableAction{}
	mock.Mock.Test(t)

	t.Cleanup(func() { mock.AssertExpectations(t) })

	return mock
}
