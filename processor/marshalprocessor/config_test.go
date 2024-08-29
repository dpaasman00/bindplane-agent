// Copyright  observIQ, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package marshalprocessor

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestConfigValidate(t *testing.T) {
	testCases := []struct {
		desc        string
		cfg         Config
		expectedErr error
	}{
		{
			desc: "JSON",
			cfg: Config{
				MarshalTo: "JSON",
			},
			expectedErr: nil,
		},
		{
			desc: "XML",
			cfg: Config{
				MarshalTo: "XML",
			},
			expectedErr: nil,
		},
		{
			desc: "KV",
			cfg: Config{
				MarshalTo: "KV",
			},
			expectedErr: nil,
		},
		{
			desc: "JSON lowercase",
			cfg: Config{
				MarshalTo: "json",
			},
			expectedErr: nil,
		},
		{
			desc: "XML lowercase",
			cfg: Config{
				MarshalTo: "xml",
			},
			expectedErr: nil,
		},
		{
			desc: "KV lowercase",
			cfg: Config{
				MarshalTo: "kv",
			},
			expectedErr: nil,
		},
		{
			desc: "error",
			cfg: Config{
				MarshalTo: "TOML",
			},
			expectedErr: errInvalidMarshalTo,
		},
	}

	for _, tc := range testCases {
		t.Run(tc.desc, func(t *testing.T) {
			actualErr := tc.cfg.Validate()
			assert.Equal(t, tc.expectedErr, actualErr)
		})
	}
}
