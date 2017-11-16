// Code generated by mockery v1.0.0
package mocks

import mock "github.com/stretchr/testify/mock"

// Client is an autogenerated mock type for the Client type
type Client struct {
	mock.Mock
}

// List provides a mock function with given fields: path
func (_m *Client) List(path string) interface{} {
	ret := _m.Called(path)

	var r0 interface{}
	if rf, ok := ret.Get(0).(func(string) interface{}); ok {
		r0 = rf(path)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(interface{})
		}
	}

	return r0
}

// NewClient provides a mock function with given fields:
func (_m *Client) NewClient() {
	_m.Called()
}

// Read provides a mock function with given fields: path
func (_m *Client) Read(path string) string {
	ret := _m.Called(path)

	var r0 string
	if rf, ok := ret.Get(0).(func(string) string); ok {
		r0 = rf(path)
	} else {
		r0 = ret.Get(0).(string)
	}

	return r0
}
