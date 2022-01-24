using System;
using System.Collections.Generic;
using System.Data;
using System.Management.Automation;
using System.Text;

namespace wwPSUtilities
{
    [Cmdlet(VerbsData.ConvertFrom, "DataRow")]
    [OutputType(typeof(PSObject))]
    public class ConvertFromDataRow : PSCmdlet
    {
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true)]
        public DataRow DataRow { get; set; }

        protected override void ProcessRecord()
        {
            PSObject outputObject = new PSObject();
            foreach (DataColumn column in DataRow.Table.Columns)
            {
                object value = DataRow.IsNull(column) ? null : DataRow[column];
                outputObject.Properties.Add(new PSNoteProperty(column.ColumnName, value));
            }

            WriteObject(outputObject);
        }
    }
}
